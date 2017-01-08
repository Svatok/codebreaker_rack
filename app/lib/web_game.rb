class WebGame < SvatokCodebreaker::Game
  def initialize(codebreaker_name = 'Test')
    super
    @file_path = File.join(File.dirname(__FILE__), 'db/scores.yml')
  end

  def save_game
    games_data = YAML.load(File.open(@file_path)) ? YAML.load(File.open(@file_path)) : {}
    games_data[games_data.count + 1] = get_game_data
    File.open(@file_path, 'r+') do |file|
      file.write(games_data.to_yaml)
    end
  end

  def load_winners(winners_count = 10)
    games_data = YAML.load(File.open(@file_path)) ? YAML.load(File.open(@file_path)) : {}
    winners = games_data.select { |_key, value| value[:marking_guess] == '++++' }.values.sort do |a, b|
      [b[:attempts], a[:hint]] <=> [a[:attempts], b[:hint]]
    end
    winners.first(winners_count)
  end
end
