# frozen_string_literal: true

dev = ENV['RACK_ENV'] == 'development'
prod = ENV['RACK_ENV'] == 'production'
require 'irb' unless prod

require 'logger'
require 'yaml'
require 'sequel'
require 'extralite'
require 'redcarpet'
require 'puma'
require 'roda'
require 'fileutils'
require 'digest'
require 'rack/deflater'
require 'fiddle'
require 'ostruct'
require 'rack/unreloader'

Unreloader = Rack::Unreloader.new(subclasses: %w[Roda Sequel::Model], reload: dev) { App }
Dir.glob('./lib/helper/**/*.rb').each { |file| Unreloader.require file }
Dir.glob('./lib/**/*.rb').each { |file| Unreloader.require file }
Unreloader.require './app.rb'

run(dev ? Unreloader : App)
