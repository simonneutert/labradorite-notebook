# frozen_string_literal: true

dev = ENV['RACK_ENV'] == 'development'

require 'yaml'
require 'tantiny'
require 'redcarpet'
require 'puma'
require 'roda'

require 'pry' if dev

require 'ostruct'

require 'rack/unreloader'
Unreloader = Rack::Unreloader.new(subclasses: %w[Roda Sequel::Model], reload: dev) { App }
Dir.glob('./lib/**/*.rb').each { |file| Unreloader.require file }
Unreloader.require './app.rb'

run(dev ? Unreloader : App)
