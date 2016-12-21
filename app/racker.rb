require 'svatok_codebreaker'
require 'erb'
require 'yaml'
lib_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(lib_root + '/lib/*.rb') { |file| require file }

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @app_message = WebGameMessage.new
    @game = @request.session[:game]
    @game_msg = @request.session[:game_msg]
    @hint = @request.session[:hint]
    @answers = @request.session[:answers].nil? ? [] : @request.session[:answers]
  end

def response
  path_without_slash = @request.path[1..-1]
  if @request.path == '/'
    @request.session.clear
    Rack::Response.new(render('index.html.erb'))
  elsif %w(exit restart hint save score game).include?(path_without_slash)
    send(('command_' + path_without_slash).to_sym)
  else
    Rack::Response.new('404 (NOT FOUND)', 404)
  end
end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def command_game
    return start_game if @game.nil?
    game_step
    @request.session[:answers] = @answers
    @request.session[:game_msg] = @game_msg
    Rack::Response.new(render('game.html.erb'))
  end

  def start_game
    return redirect_to if @request.params['codebreaker_name'].nil?
    @game = @request.session[:game] = WebGame.new(@request.params['codebreaker_name'])
    @game_msg = @app_message.show(:start)
    Rack::Response.new(render('game.html.erb'))
  end

  def game_step
    answer = @request.params['guess']
    return if answer.nil?
    return @game_msg = @app_message.show(:not_valid_answer) unless @game.valid_guess?(answer)
    @game.submit_guess(answer)
    @answers << { guess: answer, marking_guess: @app_message.show(:message_guess, @game.get_game_data) }
    @game_msg = @game.end_of_game? ? @app_message.show(:game_end, @game.get_game_data) : @app_message.show(:next_step)
  end

  def command_score
    Rack::Response.new(render('score.html.erb'))
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
    @request.session[:game] = WebGame.new(@game.codebreaker_name)
    @game_msg = @app_message.show(:restart_game)
    redirect_to('game')
  end

  def command_save
    if @game.end_of_game?
      @request.session[:command] = 'save'
      @game.save_game
      @game_msg = @app_message.show(:saved)
    else
      @game_msg = @app_message.show(:not_available)
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
