# frozen_string_literal: true

require_relative '../config/constants'

module Helper
  # Utility class for generating memo-related file paths and URLs
  #
  # Memos are stored in a hierarchical directory structure:
  # memos/YYYY/MM/DD/slug-slug/memo.md
  # memos/YYYY/MM/DD/slug-slug/meta.yaml
  #
  # @example Basic usage
  #   path = Helper::MemoPath.new("2024/01/15/abcd-efgh")
  #   path.url                 # => "/memos/2024/01/15/abcd-efgh"
  #   path.memo_file_path      # => "./memos/2024/01/15/abcd-efgh/memo.md"
  #   path.meta_file_path      # => "./memos/2024/01/15/abcd-efgh/meta.yaml"
  class MemoPath
    MEMO_FILENAME = Config::Constants::Files::MEMO_FILENAME
    META_FILENAME = Config::Constants::Files::META_FILENAME

    # Creates a new memo path helper
    #
    # @param path_id [String] the memo path ID (e.g., "2024/01/15/abcd-efgh")
    def initialize(path_id)
      @path_id = path_id
    end

    # Returns the web URL for this memo
    #
    # @return [String] the memo URL path
    def url
      "#{Config::Constants::Web::MEMOS_PATH_PREFIX}/#{@path_id}"
    end

    # Returns the file system path to the memo markdown file
    #
    # @return [String] the memo file path
    def memo_file_path
      "./memos/#{@path_id}/#{MEMO_FILENAME}"
    end

    # Returns the file system path to the memo metadata file
    #
    # @return [String] the metadata file path
    def meta_file_path
      "./memos/#{@path_id}/#{META_FILENAME}"
    end

    # Returns the file system path to the memo directory
    #
    # @return [String] the memo directory path
    def directory_path
      "./memos/#{@path_id}"
    end

    # Returns the full memo file path given a current path memo
    #
    # @param current_path_memo [String] the current memo path
    # @return [String] the full memo file path
    def full_memo_file_path(current_path_memo)
      ".#{current_path_memo}/#{MEMO_FILENAME}"
    end

    # Returns the full metadata file path given a current path memo
    #
    # @param current_path_memo [String] the current memo path
    # @return [String] the full metadata file path
    def full_meta_file_path(current_path_memo)
      ".#{current_path_memo}/#{META_FILENAME}"
    end
  end
end
