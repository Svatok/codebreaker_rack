module SvatokCodebreaker
  class GameMessage
    def show(method, game_data = nil)
      return send(method) if game_data.nil?
      send(method, game_data)
    end

    def start
      'Game started. Enter guess:'
    end

    def not_valid_answer
      'You entered is not valid answer. Enter the correct answer.'
    end

    def next_step
      'Enter a guess:'
    end

    def game_end(game_data)
      return win if game_data[:marking_guess] == '++++'
      lose(game_data[:secret_code])
    end

    def win
      'Congratulations! You win!'
    end

    def lose(secret_code)
      'Sorry, but you lose :(</br>' +
      'Secret code is ' + secret_code + '</br>'
    end

    def restart_game
      'Game restarted. Enter guess:'
    end

    def not_available
      'Sorry, but command is not available at the moment.'
    end

    def saved
      'Result saved!'
    end

    def no_hint
      'Sorry, but you have used a hint.'
    end

    def message_guess(game_data)
      return 'No match' if game_data[:marking_guess] == ''
      game_data[:marking_guess]
    end
  end
end
