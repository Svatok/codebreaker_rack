require_relative 'svatok_codebreaker.rb'
require 'erb'
require 'uri'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @app_message = SvatokCodebreaker::GameMessage.new
    @exit_game = @request.session[:exit_game].nil?
    @game = @request.session[:game]
    @game_msg = @request.session[:game_msg]
    @hint = @request.session[:hint]
    @answers = @request.session[:answers].nil? ? [] : @request.session[:answers]
  end

  def response
    @path = @request.path
    case @request.path
      when "/" then
        @request.session.clear
        Rack::Response.new(render("index.html.erb"))
      when "/game" then run_game
      when "/hint" then command_hint
      when "/exit" then command_exit
      when "/restart" then command_restart
      when "/save" then command_save
      else Rack::Response.new("404", 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def run_game
    if @game.nil?
      start_game
    else
      game_step
      @request.session[:answers] = @answers
      @request.session[:game_msg] = @game_msg
      Rack::Response.new(render('game.html.erb'))
    end
  end

  def start_game
    return redirect_to if @request.params['codebreaker_name'].nil?
    @request.session[:game] = SvatokCodebreaker::Game.new(@request.params['codebreaker_name'])
    @request.session[:exit_game] = false
    @game = @request.session[:game]
    @game_msg = @app_message.show(:start)
    Rack::Response.new(render('game.html.erb'))
  end

  def game_step
    answer = @request.params['guess']
    return if answer.nil?
    return @game_msg = @app_message.show(:not_valid_answer) unless @game.valid_guess?(answer)
    @game.submit_guess(answer)
    @answers << { :guess => answer, :marking_guess => @app_message.show(:message_guess, @game.get_game_data) }
    @game_msg = @game.end_of_game? ? @app_message.show(:game_end, @game.get_game_data) : @app_message.show(:next_step)
  end

  def command_hint
    if @game.hint
      @hint = @game.show_hint
      @game_msg = 'Hint: ' + @hint
      @request.session[:hint] = @hint
    else
      @game_msg = @app_message.show(:no_hint)
    end
    redirect_to('game')
  end

  def command_exit
    redirect_to
  end

  def command_restart
    @request.session.clear
    @request.session[:game] = SvatokCodebreaker::Game.new(@game.codebreaker_name)
    @game_msg = @app_message.show(:restart_game)
    redirect_to('game')
  end

  def command_save
    @game_msg = @app_message.show(:not_available) unless @game.end_of_game?
    if @game.end_of_game?
      @request.session[:command] = 'save'
      @game.save_game
      @game_msg = @app_message.show(:saved)
    end
    redirect_to('game')
  end

  def redirect_to(path = '')
    @request.session[:game_msg] = @game_msg unless path == ''
    Rack::Response.new do |response|
      response.redirect('/' + path)
    end
  end
end
