require 'rubygems'
require 'bundler'
Bundler.require

require './app/racker'

#use Rack::Session::Cookie, :key => 'rack.session',
#                           :path => '/',
#                           :expire_after => 2592000,
#                           :secret => 'helloworld'
use Rack::Session::Pool
use Rack::Static, :urls => ["/stylesheets", "/js", "/img"], :root => "public"

run Racker
