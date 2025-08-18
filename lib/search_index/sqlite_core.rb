# frozen_string_literal: true

require_relative 'database'
require_relative 'search_service'
require_relative 'migration'
require_relative 'fts_query_builder'
require_relative '../helper/memo_path'
require_relative '../helper/app_logger'
require_relative '../config/constants'

module SearchIndex
  # SQLite FTS5-based search index implementation
  #
  # This class provides a search interface compatible with the legacy Tantiny implementation
  # while using SQLite FTS5 for improved performance and simplified deployment.
  #
  # @example Basic usage
  #   index = SearchIndex::SqliteCore.init_index
  #   results = index.search("search term", limit: 50)
  #   index.add_memo(id: "2024/01/01/abcd", title: "Note", content: "Content")
  class SqliteCore
    MARKDOWN_DIR = Config::Constants::Files::MEMO_PATTERN

    # Initializes the search index, performing migration if needed
    #
    # @return [SqliteCore] a new search index instance
    def self.init_index
      # Perform migration if needed
      Migration.perform_if_needed

      # Return a new instance that's compatible with existing API
      new
    end

    # Creates a new search index instance
    #
    # @param database [Database] optional database instance, uses shared instance if nil
    def initialize(database = nil)
      @database = database || Database.shared
      @search_service = SearchService.new(@database)
      @query_builder = FtsQueryBuilder.new
    end

    # Recreates the search index by rebuilding from memo files
    #
    # @return [SqliteCore] self for method chaining
    def recreate_index!
      Migration.new(@database).rebuild_index
      reload
      self
    end

    # Reloads the search index (no-op for SQLite implementation)
    #
    # @return [SqliteCore] self for API compatibility
    def reload
      # SQLite doesn't need explicit reloading like Tantiny
      self
    end

    # Searches across all memo fields
    #
    # @param query [String] the search query
    # @param limit [Integer] maximum number of results to return
    # @return [Array<Array>] array of [url, title, snippet] arrays
    def search(query, limit: Config::Constants::Search::DEFAULT_SEARCH_LIMIT)
      @search_service.search(query, limit: limit)
    end

    # Searches across specific fields with field-aware query building
    #
    # @param fields [Array<String>] fields to search in (e.g., ['title', 'content'])
    # @param query [String] the search query
    # @param limit [Integer] maximum number of results to return
    # @return [Array<String>] array of memo IDs matching the query
    def search_fields(fields, query, limit: Config::Constants::Search::DEFAULT_SEARCH_LIMIT)
      # Search across multiple fields - more idiomatic than smart_query | approach
      return [] if query.nil? || query.strip.empty?

      begin
        fts_query = @query_builder.build_field_query(fields, query)
        results = execute_field_search(fts_query, limit)
        results.map { |row| row[:id] }
      rescue StandardError => e
        Helper::AppLogger.error("Search fields operation failed: #{e.message}")
        []
      end
    end

    # Executes a block within a database transaction
    #
    # @yield the block to execute within the transaction
    # @return [Object] the return value of the block
    def transaction(&block)
      @database.transaction(&block)
    end

    # Adds or updates a memo in the search index
    #
    # @param data [Hash] memo data with keys :id, :title, :tags, :content, etc.
    # @return [void]
    def add_memo(data)
      # Add file_path if missing (derive from ID)
      enhanced_data = data.dup
      enhanced_data[:file_path] ||= data[:id]
      enhanced_data[:updated_at] ||= Time.now.to_i

      @database.insert_memo(enhanced_data)
    rescue StandardError => e
      Helper::AppLogger.error("Failed to add memo to index: #{e.message}")
      raise
    end

    # Returns the number of memos in the search index
    #
    # @return [Integer] the count of indexed memos
    def count
      @database.count
    end

    private

    # Executes a field search query with ranking
    #
    # @param fts_query [String] the FTS5 query string
    # @param limit [Integer] maximum number of results
    # @return [Array<Hash>] the query results
    def execute_field_search(fts_query, limit)
      @database.db[Config::Constants::Search::FTS_TABLE].where(
        Sequel.lit('memos_fts MATCH ?', fts_query)
      ).order(
        Sequel.lit('bm25(memos_fts, ?, ?, ?)',
                   Config::Constants::Search::TITLE_WEIGHT,
                   Config::Constants::Search::TAGS_WEIGHT,
                   Config::Constants::Search::CONTENT_WEIGHT)
      ).limit(limit).select(:id).all
    end
  end
end
