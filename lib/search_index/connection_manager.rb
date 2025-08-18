# frozen_string_literal: true

require 'sequel'
require 'fileutils'
require_relative '../config/constants'
require_relative '../helper/app_logger'

module SearchIndex
  class DatabaseConnectionError < StandardError; end

  # Manages database connections, health checks, and connection statistics
  class ConnectionManager
    # Configuration for database type
    class Configuration
      attr_accessor :type, :path, :connection_timeout

      def initialize
        @type = ENV.fetch('DATABASE_TYPE', Config::Constants::Database::TYPE_MEMORY)
        @path = determine_database_path(@type)
        @connection_timeout = Config::Constants::Database::DEFAULT_CONNECTION_TIMEOUT
      end

      def in_memory?
        @type == Config::Constants::Database::TYPE_MEMORY
      end

      private

      def determine_database_path(type)
        return ':memory:' if type == Config::Constants::Database::TYPE_MEMORY

        ENV.fetch('DATABASE_PATH', default_file_path)
      end

      def default_file_path
        # Create a temporary database path for better isolation in tests
        if ENV['RACK_ENV'] == 'test'
          "tmp/#{Config::Constants::Files::TEST_SEARCH_INDEX_PREFIX}_#{Process.pid}_#{Time.now.to_i}.db"
        else
          Config::Constants::Files::DEFAULT_SEARCH_INDEX_FILE
        end
      end
    end

    attr_reader :db, :config, :connection_stats

    def initialize(config = Configuration.new)
      @config = config
      @connection_stats = initialize_connection_stats
      @db = create_connection
    end

    # Factory methods for common configurations
    def self.in_memory
      config = Configuration.new
      config.type = Config::Constants::Database::TYPE_MEMORY
      new(config)
    end

    def self.file_based(path = Config::Constants::Files::DEFAULT_SEARCH_INDEX_FILE)
      config = Configuration.new
      config.type = Config::Constants::Database::TYPE_FILE
      config.path = path
      new(config)
    end

    def close
      @db&.disconnect
    rescue StandardError => e
      Helper::AppLogger.warn("Error disconnecting database: #{e.message}")
    end

    def transaction(&block)
      @db.transaction(&block)
    rescue StandardError => e
      # Transaction will be automatically rolled back by Sequel
      Helper::AppLogger.error("Database transaction failed: #{e.message}")
      raise
    end

    def connected?
      return false unless @db

      @db.test_connection
    rescue StandardError
      false
    end

    def in_memory?
      @config.in_memory?
    end

    def ensure_connection_healthy!(schema_callback = nil)
      return if connected?

      Helper::AppLogger.error('Database connection is not healthy, attempting to reconnect...')
      track_operation(:reconnection_attempt)

      begin
        @db = create_connection
        # Call schema callback if provided (for schema recreation after reconnection)
        schema_callback&.call
        track_operation(:reconnection_success)
        Helper::AppLogger.info('Database connection restored successfully')
      rescue StandardError => e
        track_operation(:reconnection_failed)
        Helper::AppLogger.error("Failed to restore database connection: #{e.message}")
        raise DatabaseConnectionError, "Database connection is not available: #{e.message}"
      end
    end

    def track_operation(operation_type)
      @connection_stats[:operations][operation_type] += 1
      @connection_stats[:total_operations] += 1
      @connection_stats[:last_operation_at] = Time.now
    end

    def connection_info
      {
        type: @config.in_memory? ? 'in-memory' : 'file-based',
        path: @config.in_memory? ? ':memory:' : @config.path,
        connected: connected?,
        connection_stats: @connection_stats.dup
      }
    end

    private

    def create_connection
      if @config.in_memory?
        # Use true in-memory database
        Sequel.connect('extralite://')
      else
        # File-based database for persistence
        ensure_directory_exists
        Sequel.connect("extralite://#{@config.path}")
      end
    rescue StandardError => e
      raise DatabaseConnectionError, "Failed to connect to database: #{e.message}"
    end

    def ensure_directory_exists
      dir = File.dirname(@config.path)
      FileUtils.mkdir_p(dir) unless dir == '.' || File.exist?(dir)
    end

    def initialize_connection_stats
      {
        created_at: Time.now,
        operations: Hash.new(0),
        last_operation_at: nil,
        total_operations: 0
      }
    end
  end
end
