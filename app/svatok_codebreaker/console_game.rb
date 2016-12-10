module SvatokCodebreaker
  class ConsoleForGame
    def initialize
      @exit_game = false
      @menu_commands = %w(exit restart hint save)
      @console_message = GameMessage.new
    end

    def prepare_game
      puts @console_message.show(:about)
      puts @console_message.show(:login)
      @player_name = gets.chomp
      puts @console_message.show(:start)
      run_game
    end

    def run_game
      @game = Game.new(@player_name)
      until @exit_game
        answer = gets.chomp
        begin
          raise puts @console_message.show(:not_valid_answer) unless answer_valid?(answer)
          raise puts send(('command_' + answer.downcase).to_sym) if @menu_commands.include?(answer)
          @game.submit_guess(answer)
          puts @game.end_of_game? ? game_completition : @console_message.show(:next_step, @game.get_game_data)
        rescue
          next
        end
      end
    end

    def game_completition
      return @console_message.show(:win) if @game.marking_guess == '++++'
      @console_message.show(:lose, @game.get_game_data)
    end

    def answer_valid?(answer)
      @game.valid_guess?(answer) || @menu_commands.include?(answer)
    end

    def command_exit
      @exit_game = true
      @console_message.show(:exit_game)
    end

    def command_restart
      @game = Game.new(@player_name)
      @console_message.show(:restart_game)
    end

    def command_hint
      return @console_message.show(:no_hint) unless @game.hint
      @game.show_hint
    end

    def command_save
      return @console_message.show(:not_available) unless @game.end_of_game?
      @game.save_game
      @console_message.show(:saved)
    end
  end
end
