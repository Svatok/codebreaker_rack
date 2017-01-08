$LOAD_PATH.unshift File.expand_path('./app', __FILE__)
require './app/racker'
require 'rack/test'
require 'rack'
require 'capybara/rspec'
require 'rack_session_access/capybara'

app_content = File.read(File.expand_path('../../config.ru', __FILE__))
Capybara.app = eval "Rack::Builder.new {( #{app_content}\n )}"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL
end
