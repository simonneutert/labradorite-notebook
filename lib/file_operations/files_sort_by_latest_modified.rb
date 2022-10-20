module FileOperations
  #
  # Scans the filesystem and returns the latest modified file(paths)
  #
  class FilesSortByLatestModified
    #
    # returns latest memos by file modified
    #
    # @param [Integer] n number of files
    #
    # @return [Array<String>] file paths from latest to touch to least touched
    #
    def latest_n_memos_by_file_modified(n)
      all_files_order_from_least_to_newest_modified
        .last(n)
        .map! { |file_path| File.dirname(file_path) }
        .reverse
    end

    private

    #
    # scans the filesystem and retuns the last touched files by last modified state
    #
    # @return [Array<String>] of file paths
    #
    def all_files_order_from_least_to_newest_modified
      Dir.glob('memos/**/**')
         .filter { |paths| paths.match(/\.md/) }
         .sort_by { |f| File.mtime(f) }
    end
  end
end
