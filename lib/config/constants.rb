# frozen_string_literal: true

module Config
  # Centralized configuration constants for the application
  #
  # This module contains all magic numbers, file patterns, and other constants
  # used throughout the application to improve maintainability and consistency.
  module Constants
    # File and directory structure constants
    module Files
      # Memo-related file patterns and names
      MEMO_FILENAME = 'memo.md'
      META_FILENAME = 'meta.yaml'
      MEMO_PATTERN = 'memos/**/*.md'
      MEMOS_GLOB_PATTERN = 'memos/**/**'

      # Database files
      DEFAULT_SEARCH_INDEX_FILE = 'search_index.db'
      TEST_SEARCH_INDEX_PREFIX = 'test_search_index'

      # Temporary file patterns
      TEMP_DB_PATTERN = ['search_index', '.db'].freeze
    end

    # Search and pagination defaults
    module Search
      # Default pagination and limits
      DEFAULT_SEARCH_LIMIT = 100          # Standard search result limit
      DEFAULT_RECENT_MEMOS_COUNT = 25     # Homepage recent memos
      PREVIEW_SEARCH_LIMIT = 3            # Homepage search preview limit
      MEGA_SEARCH_LIMIT = 10_000          # Maximum for comprehensive "Search All" feature

      # FTS5 ranking weights for BM25 scoring
      # Higher values = more important fields
      TITLE_WEIGHT = 2.0
      TAGS_WEIGHT = 1.5
      CONTENT_WEIGHT = 1.0

      # Database table names
      FTS_TABLE = :memos_fts
      METADATA_TABLE = :memos_metadata
    end

    # Database configuration
    module Database
      # Connection settings
      DEFAULT_CONNECTION_TIMEOUT = 30

      # Database types
      TYPE_MEMORY = 'memory'
      TYPE_FILE = 'file'

      # Environment defaults
      DEFAULT_LOG_LEVEL_PRODUCTION = 'INFO'
      DEFAULT_LOG_LEVEL_DEVELOPMENT = 'DEBUG'
    end

    # File upload restrictions
    module Upload
      # Supported file extensions (already defined in MEDIA_WHITELIST but centralized here for reference)
      ALLOWED_EXTENSIONS = %w[
        txt pdf md png jpg jpeg heic webp yml yaml json gpx
      ].freeze
    end

    # Application routing and web constants
    module Web
      # Route patterns and paths
      MEMOS_PATH_PREFIX = '/memos'
      API_V1_PREFIX = '/api/v1'

      # File serving patterns
      MEMO_PATH_PATTERN = %r{(\d{4}/\d{1,2}/\d{1,2}/\w{4}-\w{4})}
      ATTACHMENT_PATH_PATTERN = %r{memos/(\d{4}/\d{1,2}/\d{1,2}/\w{4}-\w{4})/(.*\.(#{Upload::ALLOWED_EXTENSIONS.join('|')}))}
    end
  end
end
