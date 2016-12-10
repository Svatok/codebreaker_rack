module SvatokCodebreaker
  ATTEMPTS = 10

  class Game
    attr_accessor :attempts, :codebreaker_name, :hint, :marking_guess

    def initialize(codebreaker_name = 'Test')
      @codebreaker_name = codebreaker_name
      @secret_code = Array.new(4) { rand(1..6) }.join
      @attempts = ATTEMPTS
      @hint = true
      @file_path = File.join(File.dirname(__FILE__), 'scores.txt')
    end

    def submit_guess(guess)
      return if end_of_game?
      @attempts -= 1
      @marking_guess = Marker.new(@secret_code, guess).marking_guess
    end

    def valid_guess?(guess)
      return false unless !!guess
      return false unless guess.length == 4
      return false unless /[1-6]+/=~guess
      true
    end

    def end_of_game?
      @marking_guess == '++++' || @attempts.zero?
    end

   def show_hint
     @hint = false
     @secret_code.chars.sample
   end

    def save_game
      score_file = File.open(@file_path, 'a')
      score_file.puts get_game_data.map { |k, v| "#{k}=#{v}" }.join(';')
      score_file.close
    end

    def get_game_data
      {
        codebreaker_name: @codebreaker_name,
        secret_code: @secret_code,
        marking_guess: @marking_guess,
        attempts: @attempts,
        hint: @hint == true ? 'not used' : 'used',
        game_date: Time.now.strftime('%d/%m/%Y')
      }
    end
  end
end
