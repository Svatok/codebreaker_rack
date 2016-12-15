require 'rubygems'
require 'bundler'
Bundler.require

require './app/racker'

use Rack::Session::Pool
use Rack::Static, :urls => ["/stylesheets", "/js", "/img"], :root => "public"

run Racker
