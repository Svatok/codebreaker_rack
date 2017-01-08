require 'rubygems'
require 'bundler'
Bundler.require

require './app/racker'

use Rack::Session::Cookie, key: 'rack.session',
                          secret: 'secretKey'
use RackSessionAccess::Middleware
use Rack::Static, :urls => ["/stylesheets", "/js", "/img"], :root => "public"

run Racker
