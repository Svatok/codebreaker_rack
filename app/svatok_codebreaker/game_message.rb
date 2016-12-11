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

    def win
      'Congratulations! You win!'
    end

    def lose(game_data)
      'Sorry, but you lose :(</br>' +
      'Secret code is ' + game_data[:secret_code] + '</br>'
    end

    def restart_game
      'Game restarted. Enter guess:'
    end

    def not_available
      'Sorry, but command is not available at the moment.'
    end

    def saved
      'Score saved!'
    end

    def no_match
      'Sorry, but there is no match...'
    end

    def no_hint
      'Sorry, but you have used a hint.'
    end

    def message_guess(game_data)
      return 'Sorry, but there is no match...' if game_data[:marking_guess] == ''
      game_data[:marking_guess]
    end
  end
end
