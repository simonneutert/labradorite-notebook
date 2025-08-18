# frozen_string_literal: true

require_relative '../helper/memo_path'
require_relative '../helper/app_logger'
require_relative '../config/constants'

module SearchIndex
  class Migration
    def initialize(database = nil)
      @db = database || Database.shared
    end

    def self.perform_if_needed
      migration = new
      if migration.needs_migration?
        migration.migrate_from_tantiny
      elsif migration.needs_index_rebuild?
        migration.rebuild_index
      end
    rescue StandardError => e
      Helper::AppLogger.error("Search index migration failed: #{e.message}")
      Helper::AppLogger.warn('Application will continue with empty search index')
      # Continue execution - the app should still work without search
    end

    def needs_migration?
      !@db.index_exists?
    end

    def needs_index_rebuild?
      !@db.index_exists? || @db.count.zero? # rubocop:disable Style/CollectionQuerying
    end

    def migrate_from_tantiny
      Helper::AppLogger.info('Migrating from Tantiny to SQLite FTS5...')

      # Remove old Tantiny index
      cleanup_tantiny_index

      # Rebuild index from memo files
      rebuild_index

      Helper::AppLogger.info('Migration completed successfully!')
    end

    def rebuild_index
      Helper::AppLogger.info('Building search index...')

      # Extract data from files (same as original Tantiny implementation)
      memo_data = extract_memo_data

      # Bulk insert into SQLite
      search_service = SearchService.new(@db)
      search_service.bulk_insert(memo_data)

      Helper::AppLogger.info("Index built with #{@db.count} memos")
    end

    private

    def cleanup_tantiny_index
      return unless Dir.exist?(Config::Constants::Files::LEGACY_SEARCH_INDEX_DIR)

      Helper::AppLogger.info('Removing old Tantiny index...')
      FileUtils.rm_rf(Config::Constants::Files::LEGACY_SEARCH_INDEX_DIR)
    end

    def extract_memo_data
      markdown_pattern = Config::Constants::Files::MEMO_PATTERN
      find_memo_files(markdown_pattern).filter_map { |md_file| process_memo_file(md_file) }
    end

    # Finds and filters memo files that are valid for processing
    def find_memo_files(markdown_pattern)
      Dir.glob(markdown_pattern).filter do |md_file|
        valid_memo_file?(md_file)
      end
    end

    # Checks if a file is a valid memo file with corresponding metadata
    def valid_memo_file?(md_file)
      return false unless File.basename(md_file) == Helper::MemoPath::MEMO_FILENAME

      meta_file = build_meta_file_path(md_file)
      File.exist?(meta_file)
    end

    # Processes a single memo file and returns structured data
    def process_memo_file(md_file)
      meta_file = build_meta_file_path(md_file)

      begin
        meta = load_metadata(meta_file)
        content = File.read(md_file)
        relative_path = extract_relative_path(md_file)

        build_memo_data(meta, content, relative_path)
      rescue StandardError => e
        Helper::AppLogger.warn("Failed to process #{md_file}: #{e.message}")
        nil
      end
    end

    # Builds the metadata file path from a markdown file path
    def build_meta_file_path(md_file)
      md_file.gsub(Helper::MemoPath::MEMO_FILENAME, Helper::MemoPath::META_FILENAME)
    end

    # Loads and parses metadata from a YAML file
    def load_metadata(meta_file)
      YAML.safe_load_file(meta_file, permitted_classes: [Date, Time, DateTime])
    end

    # Extracts the relative path identifier from the full file path
    def extract_relative_path(md_file)
      md_file.gsub('memos/', '').gsub("/#{Helper::MemoPath::MEMO_FILENAME}", '')
    end

    # Builds the final memo data structure
    def build_memo_data(meta, content, relative_path)
      {
        id: meta['id'] || relative_path,
        title: meta['title']&.strip || 'Untitled',
        tags: format_tags(meta['tags']),
        content: content,
        updated_at: extract_timestamp(meta),
        file_path: relative_path
      }
    end

    def format_tags(tags)
      return '' if tags.nil?

      case tags
      when Array
        tags.join(' ')
      when String
        tags
      else
        tags.to_s
      end
    end

    def extract_timestamp(meta)
      timestamp = meta['updated_at'] || meta['created_at'] || Time.now

      case timestamp
      when Time
        timestamp.to_i
      when DateTime, Date
        timestamp.to_time.to_i
      when String
        begin
          Time.parse(timestamp).to_i
        rescue ArgumentError => e
          Helper::AppLogger.warn("Failed to parse timestamp '#{timestamp}': #{e.message}")
          Time.now.to_i
        end
      else
        Time.now.to_i
      end
    end
  end
end
