$LOAD_PATH.unshift File.expand_path('./app', __FILE__)
require './app/racker'
require 'rack/test'
require 'rack'
RSpec.configure do |config|
  config.include Rack::Test::Methods
end
