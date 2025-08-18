# frozen_string_literal: true

require_relative '../config/constants'

module SearchIndex
  # Manages database schema creation, validation, and operations
  class SchemaManager
    def initialize(connection_manager)
      @connection_manager = connection_manager
    end

    def create_schema
      @connection_manager.db.run <<~SQL
        CREATE VIRTUAL TABLE IF NOT EXISTS memos_fts USING fts5(
          id UNINDEXED,
          title,
          tags,
          content,
          updated_at UNINDEXED
        );
      SQL

      @connection_manager.db.run <<~SQL
        CREATE TABLE IF NOT EXISTS memos_metadata (
          id TEXT PRIMARY KEY,
          file_path TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        );
      SQL

      @connection_manager.db.run <<~SQL
        CREATE INDEX IF NOT EXISTS idx_memos_metadata_updated_at
        ON memos_metadata(updated_at);
      SQL
    end

    def schema_exists?
      @connection_manager.db.table_exists?(:memos_fts) &&
        @connection_manager.db.table_exists?(:memos_metadata)
    end

    def clear_index
      # Only clear if schema exists
      return unless schema_exists?

      @connection_manager.db.run "DELETE FROM #{Config::Constants::Search::FTS_TABLE}"
      @connection_manager.db.run "DELETE FROM #{Config::Constants::Search::METADATA_TABLE}"
    end

    def index_exists?
      if @connection_manager.in_memory?
        schema_exists? # In-memory DB exists if schema is created
      else
        File.exist?(@connection_manager.config.path) && schema_exists?
      end
    end

    def needs_migration?
      !index_exists?
    end

    def insert_memo(data)
      @connection_manager.transaction do
        # Ensure schema exists before inserting
        create_schema unless schema_exists?

        # Perform upsert operation (delete existing + insert new)
        delete_existing_memo(data[:id])
        insert_new_memo(data)
      end
    end

    def search(query, limit: Config::Constants::Search::DEFAULT_SEARCH_LIMIT)
      @connection_manager.ensure_connection_healthy!(-> { create_schema unless schema_exists? })
      @connection_manager.track_operation(:search)

      execute_fts_search(query, limit)
    rescue StandardError => e
      @connection_manager.track_operation(:search_failed)
      require_relative '../helper/app_logger'
      Helper::AppLogger.error("Database search failed: #{e.message}")
      []
    end

    def count
      @connection_manager.ensure_connection_healthy!(-> { create_schema unless schema_exists? })
      @connection_manager.track_operation(:count)
      @connection_manager.db[Config::Constants::Search::FTS_TABLE].count
    rescue StandardError => e
      @connection_manager.track_operation(:count_failed)
      require_relative '../helper/app_logger'
      Helper::AppLogger.error("Database count failed: #{e.message}")
      0
    end

    def schema_info
      {
        schema_exists: schema_exists?,
        record_count: count
      }
    end

    private

    # Executes FTS search query with ranking
    def execute_fts_search(query, limit)
      @connection_manager.db[Config::Constants::Search::FTS_TABLE].where(
        Sequel.lit('memos_fts MATCH ?', query)
      ).order(
        Sequel.lit('bm25(memos_fts, ?, ?, ?)',
                   Config::Constants::Search::TITLE_WEIGHT,
                   Config::Constants::Search::TAGS_WEIGHT,
                   Config::Constants::Search::CONTENT_WEIGHT)
      ).limit(limit).all
    end

    # Deletes existing memo entries from both FTS and metadata tables
    def delete_existing_memo(memo_id)
      @connection_manager.db[:memos_fts].where(id: memo_id).delete
      @connection_manager.db[:memos_metadata].where(id: memo_id).delete
    end

    # Inserts new memo data into both FTS and metadata tables
    def insert_new_memo(data)
      insert_fts_entry(data)
      insert_metadata_entry(data)
    end

    # Inserts memo into the FTS table
    def insert_fts_entry(data)
      @connection_manager.db[:memos_fts].insert(
        id: data[:id],
        title: data[:title],
        tags: data[:tags],
        content: data[:content],
        updated_at: data[:updated_at]
      )
    end

    # Inserts memo metadata into the metadata table
    def insert_metadata_entry(data)
      @connection_manager.db[:memos_metadata].insert(
        id: data[:id],
        file_path: data[:file_path],
        updated_at: data[:updated_at] || Time.now.to_i
      )
    end
  end
end
