module FileOperations
  class FilesSortByLatestModified
    def latest_n_memos(n)
      latest_n_memos_by_file_modified(n)
    end

    def latest_n_memos_by_file_modified(n)
      all_files_order_from_least_to_newest_modified
        .last(n)
        .map! { |file_path| File.dirname(file_path) }
        .reverse
    end

    private

    def all_files_order_from_least_to_newest_modified
      Dir.glob('memos/**/**')
         .filter { |paths| paths.match(/\.md/) }
         .sort_by { |f| File.mtime(f) }
    end
  end
end
