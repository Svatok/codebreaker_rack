require_relative 'svatok_codebreaker.rb'
require 'erb'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @exit_game = (@request.session[:exit_game] || @request.session[:exit_game].nil?)
    @request.session[:menu_commands] ||= %w(exit restart hint save)
    @request.session[:answers] ||= {}
    @game_msg = @request.session[:game_msg]
    @app_message = SvatokCodebreaker::GameMessage.new
    @game = @request.session[:game]
  end

  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
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
      @request.session[:game] = SvatokCodebreaker::Game.new(@request.params['codebreaker_name'])
      @request.session[:exit_game] = false
      @game = @request.session[:game]
    else
      game_step
    end
    @request.session[:answers] = @answers
    Rack::Response.new(render("game.html.erb"))
  end

  def game_step
    return redirect_to if @exit_game
    answer = @request.params['guess']
    @game_msg = @app_message.show(:not_valid_answer) unless @game.valid_guess?(answer)
    @game.submit_guess(answer) if @game.valid_guess?(answer)
    @game_msg = @game.end_of_game? ? game_completition : @app_message.show(:next_step, @game.get_game_data)
  end

  def game_completition
    return @app_message.show(:win) if @game.marking_guess == '++++'
    @app_message.show(:lose, @game.get_game_data)
  end

  def command_hint
    @game_msg = @game.hint ? @game.show_hint : @app_message.show(:no_hint)
    redirect_to('game')
  end

  def command_exit
    @exit_game = true
    redirect_to
  end

  def command_restart
    @request.session[:game] = SvatokCodebreaker::Game.new(@game.instance_variable_get(:@player_name))
    @game_msg = @app_message.show(:restart_game)
    redirect_to('game')
  end

  def command_save
    @game_msg = @app_message.show(:not_available) unless @game.end_of_game?
    if @game.end_of_game?
      @game.save_game
      @game_msg = @app_message.show(:saved)
    end
    redirect_to('game')
  end

  def redirect_to(path = '')
    @request.session[:game_msg] = @game_msg
    Rack::Response.new do |response|
      response.redirect('/' + path)
    end
  end


end
