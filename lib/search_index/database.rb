# frozen_string_literal: true

require_relative 'connection_manager'
require_relative 'schema_manager'
require_relative '../config/constants'

module SearchIndex
  # Main database interface that coordinates between connection and schema management
  class Database
    attr_reader :connection_manager, :schema_manager

    def initialize(config = nil)
      @connection_manager = if config
                              ConnectionManager.new(config)
                            else
                              ConnectionManager.new
                            end
      @schema_manager = SchemaManager.new(@connection_manager)

      # Initialize schema
      @schema_manager.create_schema unless @schema_manager.schema_exists?
    end

    # Delegate connection-related methods to connection_manager
    def db
      @connection_manager.db
    end

    def config
      @connection_manager.config
    end

    def connection_stats
      @connection_manager.connection_stats
    end

    # More idiomatic Ruby: module-level shared instance
    def self.shared
      @shared ||= new
    end

    # For future scaling: simple connection statistics
    def self.connection_summary
      return { status: 'no_shared_instance' } unless @shared

      {
        status: 'active',
        instance_created: @shared.connection_stats[:created_at],
        total_operations: @shared.connection_stats[:total_operations],
        operations_breakdown: @shared.connection_stats[:operations],
        last_operation: @shared.connection_stats[:last_operation_at],
        currently_connected: @shared.connected?
      }
    end

    # For tests: reset the shared instance
    def self.reset_shared!
      return unless @shared

      begin
        @shared.close
      rescue StandardError => e
        # Log but don't raise - we're in cleanup mode
        require_relative '../helper/app_logger'
        Helper::AppLogger.warn("Error closing shared database connection: #{e.message}")
      ensure
        @shared = nil
      end

      # For in-memory databases, immediately create a new instance to ensure schema exists
      if ENV.fetch('DATABASE_TYPE', Config::Constants::Database::TYPE_MEMORY) == Config::Constants::Database::TYPE_MEMORY
        shared
      end
    end

    # Factory methods for common configurations
    def self.in_memory
      new(ConnectionManager::Configuration.new.tap { |c| c.type = Config::Constants::Database::TYPE_MEMORY })
    end

    def self.file_based(path = Config::Constants::Files::DEFAULT_SEARCH_INDEX_FILE)
      new(ConnectionManager::Configuration.new.tap do |c|
        c.type = Config::Constants::Database::TYPE_FILE
        c.path = path
      end)
    end

    # Delegate connection-related methods to connection_manager
    def close
      @connection_manager.close
    end

    def transaction(&block)
      @connection_manager.transaction(&block)
    end

    def connected?
      @connection_manager.connected?
    end

    def in_memory?
      @connection_manager.in_memory?
    end

    # Delegate schema-related methods to schema_manager
    def create_schema
      @schema_manager.create_schema
    end

    def schema_exists?
      @schema_manager.schema_exists?
    end

    def clear_index
      @schema_manager.clear_index
    end

    def index_exists?
      @schema_manager.index_exists?
    end

    def needs_migration?
      @schema_manager.needs_migration?
    end

    def insert_memo(data)
      @schema_manager.insert_memo(data)
    end

    def search(query, limit: Config::Constants::Search::DEFAULT_SEARCH_LIMIT)
      @schema_manager.search(query, limit: limit)
    end

    def count
      @schema_manager.count
    end

    def database_info
      @connection_manager.connection_info.merge(@schema_manager.schema_info)
    end
  end
end
