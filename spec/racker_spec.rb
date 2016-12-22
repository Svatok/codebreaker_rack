require 'spec_helper'

describe Racker do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  context 'get to /' do
    let(:response) { get '/' }
    it 'returns the status 200' do
      expect(response.status).to eq 200
    end
    it 'returns index page' do
      file = File.open('./spec/standarts/index.html', 'rb')
      contents = file.read
      expect(response.body).to eq contents
    end
    it 'clear session' do
      env('rack.session', game: WebGame.new('Test'))
      response
      expect(last_request.env['rack.session']).to be_empty
    end
  end

  context 'game start' do
    let(:response) { get '/game', 'codebreaker_name' => 'Test' }
    it 'returns the status 200' do
      expect(response.status).to eq 200
    end
    it 'start session' do
      response
      expect(last_request.env['rack.session']).not_to be_empty
    end
    it 'returns page with game process: game start' do
      content = File.open('./spec/standarts/game_start.html', 'rb').read
      expect(response.body.gsub(/\s+/, '')).to eq content.gsub(/\s+/, '')
    end
  end

  context 'game step' do
    let(:response) do
      game_obj = WebGame.new('Test')
      game_obj.instance_variable_set(:@secret_code, '1255')
      get '/game', { 'guess' => '1234' }, { 'rack.session' => { game: game_obj } }
    end

    it 'returns the status 200' do
      expect(response.status).to eq 200
    end
    it 'returns page with game process: game step' do
      response
      content = File.open('./spec/standarts/game_step.html', 'rb').read
      expect(last_response.body.gsub(/\s+/, '')).to eq content.gsub(/\s+/, '')
    end
  end

  context 'show score' do
    let(:response) do
      games_data = YAML.load(File.open('./spec/standarts/scores.yml'))
      get '/score', { 'guess' => '1234' }, { 'rack.session' => { game: WebGame.new('Test') }, answers: games_data }
    end

    it 'returns the status 200' do
      expect(response.status).to eq 200
    end
    it 'returns page with winner results' do
      response
      content = File.open('./spec/standarts/scores.html', 'rb').read
      expect(last_response.body.gsub(/\s+/, '')).to eq content.gsub(/\s+/, '')
    end
  end

  context 'press exit game' do
    let(:response) { get '/exit' }

    it 'redirect to /' do
      response
      follow_redirect!
      expect(last_request.url).to eql('http://example.org/')
    end
  end

  context 'press restart game' do
    let(:game_page) { get '/game', {}, 'rack.session' => { game: WebGame.new('Test') } }
    let(:response) { get '/restart' }

    it 'create new game object' do
      game_page
      old_game = last_request.env['rack.session'][:game]
      response
      expect(last_request.env['rack.session'][:game]).not_to eql(old_game)
    end
    it 'redirect to /game' do
      game_page
      response
      follow_redirect!
      expect(last_request.url).to eql('http://example.org/game')
    end
    it 'page with game include message about game restart' do
      game_page
      response
      follow_redirect!
      expect(last_response.body).to include('Game restarted. Enter guess:')
    end
  end

  context 'press hint' do
    let(:response) { get '/hint', {}, 'rack.session' => { game: WebGame.new('Test') } }

    it 'show hint if before it was not used' do
      response
      follow_redirect!
      expect(last_response.body).to include('Hint: ' + last_request.env['rack.session'][:hint])
    end
    it 'redirect to /game' do
      response
      follow_redirect!
      expect(last_request.url).to eql('http://example.org/game')
    end
  end

  context 'unknown request' do
    let(:response) { get '/unknown' }

    it 'returns 404 response' do
      expect(response.status).to eql(404)
    end
    it 'returns page 404' do
      expect(response.body).to eql('404 (NOT FOUND)')
    end
  end
end
