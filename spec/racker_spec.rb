require 'spec_helper'

describe Racker do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  context 'get to /' do
    let(:response) { get '/' }
    it 'returns the status 200' do
      expect(response.status).to eq 200
    end
    it 'returns index page' do
      file = File.open('./spec/Codebreaker.html', 'rb')
      contents = file.read
      expect(response.body).to eq contents
    end
    it 'clear session' do
      env('rack.session', game: WebGame.new('Test'))
      response
      expect(last_request.env['rack.session']).to be_empty
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
end
