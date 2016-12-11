require_relative 'svatok_codebreaker.rb'
require 'erb'
require 'uri'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @exit_game = @request.session[:exit_game].nil?
    @request.session[:menu_commands] ||= %w(exit restart hint save)
    @game_msg = @request.session[:game_msg]
    @app_message = SvatokCodebreaker::GameMessage.new
    @game = @request.session[:game]
    @request.session[:guess] = @request.params['guess'] unless @request.params['guess'].nil?
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
      Rack::Response.new(render("game.html.erb"))
    end
  end

  def start_game
    return redirect_to if @request.params['codebreaker_name'].nil?
    @request.session[:game] = SvatokCodebreaker::Game.new(@request.params['codebreaker_name'])
    @request.session[:exit_game] = false
    @game = @request.session[:game]
    @game_msg = @app_message.show(:start)
    Rack::Response.new(render("game.html.erb"))
  end

  def game_step
    answer = @request.params['guess']
    return if answer.nil?
    return @game_msg = @app_message.show(:not_valid_answer) unless @game.valid_guess?(answer)
    @game.submit_guess(answer)
    @game_msg = @app_message.show(:next_step) unless @game.end_of_game?
  end

  def game_completition
    return @app_message.show(:win) if @game.marking_guess == '++++'
    @app_message.show(:lose, @game.get_game_data)
  end

  def command_hint
    @game_msg = @game.hint ? 'Hint: ' + @game.show_hint : @app_message.show(:no_hint)
    redirect_to('game')
  end

  def command_exit
    redirect_to
  end

  def command_restart
    @request.session.clear
    @request.session[:game] = SvatokCodebreaker::Game.new(@game.instance_variable_get(:@player_name))
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
