# frozen_string_literal: true

dev = ENV['RACK_ENV'] == 'development'

require 'yaml'
require 'sequel'
require 'extralite'
require 'redcarpet'
require 'puma'
require 'roda'

require 'irb' if dev

require 'ostruct'
require 'rack/builder'
require 'rack/test'

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

# Ensure database cleanup between test runs
require 'minitest/autorun'

class Minitest::Test # rubocop:disable Style/ClassAndModuleChildren
  def setup
    super
    # Reset shared database instance before each test to ensure isolation
    SearchIndex::Database.reset_shared!
  end

  def teardown
    super
    # Clean up database connections after each test
    SearchIndex::Database.reset_shared!
  end
end
