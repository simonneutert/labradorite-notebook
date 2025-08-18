# frozen_string_literal: true

require_relative '../helper/app_logger'
require_relative '../config/constants'

module SearchIndex
  class SearchService
    def initialize(database = nil)
      @db = database || Database.shared
    end

    def search(query, limit: Config::Constants::Search::DEFAULT_SEARCH_LIMIT)
      return [] if query.nil? || query.strip.empty?

      begin
        # Build FTS5 query for multi-field search
        fts_query = build_fts_query(query)

        results = @db.db[Config::Constants::Search::FTS_TABLE].where(
          Sequel.lit('memos_fts MATCH ?', fts_query)
        ).order(
          Sequel.lit('bm25(memos_fts, ?, ?, ?)',
                     Config::Constants::Search::TITLE_WEIGHT,
                     Config::Constants::Search::TAGS_WEIGHT,
                     Config::Constants::Search::CONTENT_WEIGHT)
        ).limit(limit).all

        # Generate snippets and format results
        format_results(results, query)
      rescue StandardError => e
        Helper::AppLogger.error("Search failed: #{e.message}")
        []
      end
    end

    def bulk_insert(memos_data)
      @db.transaction do
        # Ensure schema exists before clearing/inserting
        @db.create_schema unless @db.schema_exists?
        @db.clear_index

        memos_data.each do |data|
          @db.insert_memo(data)
        end
      end
    rescue StandardError => e
      Helper::AppLogger.error("Bulk insert operation failed: #{e.message}")
      raise
    end

    def index_count
      @db.count
    rescue StandardError => e
      Helper::AppLogger.error("Failed to get index count: #{e.message}")
      0
    end

    private

    def build_fts_query(query)
      # Escape special FTS5 characters except *
      escaped_query = query.gsub(/['"]/, '')

      # Build queries for both exact match and prefix match
      terms = escaped_query.split(/\s+/).map(&:strip).reject(&:empty?)

      query_parts = []
      fields = %w[title tags content]

      terms.each do |term|
        # For each term, try both exact match and prefix match
        field_exact = fields.map { |field| "#{field}:#{term}" }
        field_prefix = fields.map { |field| "#{field}:#{term}*" }

        # Combine exact and prefix matches with OR
        term_query = (field_exact + field_prefix).join(' OR ')
        query_parts << "(#{term_query})"
      end

      # Join multiple terms with AND to require all terms to match
      query_parts.join(' AND ')
    end

    def format_results(results, original_query)
      # Create regex once for all results
      query_regex = /#{Regexp.escape(original_query)}/i
      results.map do |row|
        # Generate snippet from content
        snippet = generate_snippet(row[:content], query_regex)

        # Build file path from ID (assuming ID contains the path structure)
        url = "#{Config::Constants::Web::MEMOS_PATH_PREFIX}/#{row[:id]}"

        [url, row[:title], snippet]
      end
    end

    def generate_snippet(content, query_regex)
      return [] if content.nil? || content.empty?

      # Simple snippet generation - find lines containing the query
      lines = content.split("\n")

      # Return all matching lines without truncation to preserve backward compatibility
      lines.grep(query_regex)
    end
  end
end
