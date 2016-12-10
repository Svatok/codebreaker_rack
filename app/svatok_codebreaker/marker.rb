module SvatokCodebreaker
  class Marker
    def initialize(secret_code, guess)
      @secret_code = secret_code.split('')
      @guess = guess.split('')
    end

    def marking_guess
      return '++++' if @secret_code == @guess
      mark = marking_exact_matches
      mark += marking_inexact_matches
      mark.join
    end

    def marking_exact_matches
      @guess.each_with_index.map do |number, index|
        next unless number == @secret_code[index]
        @guess[index] = nil
        @secret_code[index] = nil
        '+'
      end
    end

    def marking_inexact_matches
      [@guess, @secret_code].each(&:compact!)
      @guess.map do |number|
        next unless @secret_code.include?(number)
        @secret_code[@secret_code.find_index(number)] = nil
        '-'
      end
    end
  end
end
