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
Dir.glob('./lib/**/*.rb').each do |file|
  puts file
  Unreloader.require file
end
Unreloader.require './app.rb'

INDEX = Tantiny::Index.new '.tantiny', exclusive_writer: dev do
  id :id
  facet :category
  string :title
  text :content
  date :updated_at
end

run(dev ? Unreloader : App)
