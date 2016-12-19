class WebGame < SvatokCodebreaker::Game
  def save_game
    @file_path = File.join(File.dirname(__FILE__), 'scores.txt')
    super
  end

  def load_winners(winners_count = 10)
  end
end
