module SvatokCodebreaker
  class GameMessage
    def show(method, game_data = nil)
      return send(method) if game_data.nil?
      send(method, game_data)
    end

    def about
      "\n--------------------CODEBREAKER--------------------\n" +
      "\nCodebreaker is a logic game in which a player" +
      "\ntries to break a secret code created by a computer. The" +
      "\ncode-maker, which will be played by the application were" +
      "\ngoing to write, creates a secret code of four numbers" +
      "\nbetween 1 and 6.\n" +
      "\nComputer creates a secret code of four numbers between 1" +
      "\nand 6. You get " + ATTEMPTS.to_s + " chances to break the code." +
      "\nIn each turn, you make a guess of four numbers. Computer" +
      "\nthen marks the guess with up to four + and - signs." +
      "\n  A + indicates an exact match: one of the numbers in the guess" +
      "\nis the same as one of the numbers in the secret code and" +
      "\nin the same position." +
      "\n  A - indicates a number match: one of the numbers in the guess" +
      "\nis the same as one of the numbers in the secret code but in a" +
      "\ndifferent position." +
      "\n  At any time during a game, you can request a hint, at which" +
      "\npoint the system reveals one of the numbers in the" +
      "\nsecret code. After the game is won or lost, you can opt" +
      "\nto save information about the game.\n" +
      "\nDuring the game you can use the commands Exit, Restart," +
      "\nHint, Save."
    end

    def login
      "\nPlease, enter your name:"
    end

    def start
      "\n----------Game started. Enter guess:----------"
    end

    def not_valid_answer
      "\nYou entered is not valid answer. Enter the correct answer."
    end

    def next_step(game_data)
      'Enter a guess:'
    end

    def win
      "\n" + "----------Congratulations! You win!----------\n" +
      commands
    end

    def lose(game_data)
      "\n" + message_guess(game_data[:marking_guess]) + "\n" +
      "----------Sorry, but you lose :(----------\n" +
      'Secret code is ' + game_data[:secret_code] + "\n" +
      commands
    end

    def commands
      'You can Exit/Restart/Save. Enter the desired command:'
    end

    def exit_game
      "\n----------Bye!----------"
    end

    def restart_game
      "\n----------Game restarted. Enter guess:----------"
    end

    def not_available
      "\nSorry, but command is not available at the moment."
    end

    def saved
      "\n----------Score saved!---------"
    end

    def no_match
      "\nSorry, but there is no match..."
    end

    def no_hint
      "\nSorry, but you have used a hint."
    end

    def message_guess(guess)
      return 'Sorry, but there is no match...' if guess == ''
      guess
    end
  end
end
