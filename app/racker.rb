require_relative 'svatok_codebreaker.rb'
require 'erb'
require 'uri'

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
    @request.session[:guess] = @request.params['guess'] unless @request.params['guess'].nil?
  end

  def response
    @path = @request.path
    case @request.path
      when "/" then Rack::Response.new(render("index.html.erb"))
      when "/game" then run_game
      when "/hint" then
        @request.session[:command] = 'hint'
        redirect_to('game')
      when "/exit" then command_exit
      when "/restart" then #command_restart
        @request.session[:command] = 'restart'
        redirect_to('game')
      when "/save" then command_save
      else Rack::Response.new("404", 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def run_game
    @game.nil? ? start_game : game_step
    Rack::Response.new(render("game.html.erb"))
  end

  def start_game
    @request.session[:game] = SvatokCodebreaker::Game.new(@request.params['codebreaker_name'])
    @request.session[:exit_game] = false
    @game = @request.session[:game]
  end

  def game_step
    redirect_to if @exit_game
    answer = @request.params['guess'].nil? ? @request.session[:command] : @request.session[:guess]
    return @game_msg = @app_message.show(:not_valid_answer) unless answer_valid?(answer)
    return send(('command_' + answer.downcase).to_sym) if menu_command?(answer)
    @game.submit_guess(answer)
    @game_msg = @game.end_of_game? ? game_completition : @app_message.show(:next_step, @game.get_game_data)
  end

  def game_completition
    return @app_message.show(:win) if @game.marking_guess == '++++'
    @app_message.show(:lose, @game.get_game_data)
  end

  def answer_valid?(answer)
    @game.valid_guess?(answer) || menu_command?(answer)
  end

  def menu_command?(answer)
    @request.session[:menu_commands].include?(answer)
  end

  def command_hint
    @game_msg = @game.hint ? @game.show_hint : @app_message.show(:no_hint)
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
      @request.session[:command] = 'save'
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
