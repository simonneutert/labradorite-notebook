dev = ENV['RACK_ENV'] == 'development'

require 'yaml'
require 'tantiny'
require 'redcarpet'
require 'puma'
require 'roda'

require 'pry' if dev

require 'ostruct'

# require 'rack/unreloader'
# Unreloader = Rack::Unreloader.new(subclasses: %w[Roda Sequel::Model], reload: dev) { App }
Dir.glob('./lib/helper/**/*.rb').each do |file|
  puts file
  require(file)
end
Dir.glob('./lib/**/*.rb').each do |file|
  puts file
  require(file)
end
