module FileOperations
  #
  # Deletes a Memo and its Meta Data and Attachments
  #
  class DeleteMemo
    attr_reader :memo_path, :current_path_memo

    include Helper::DeepCopyable

    def initialize(memo_path, current_path_memo)
      @memo_path = deep_copy(memo_path)
      @current_path_memo = deep_copy(current_path_memo)
    end

    #
    # deletes a memo and everything inside the directory
    #
    # @return [TrueClass]
    #
    def run
      FileUtils.remove_dir("./#{@current_path_memo}")
      top_path = @memo_path.split('/').take(3).join('/')
      path = "./memos/#{top_path}"
      FileUtils.remove_dir(path) if Dir.glob("#{path}/**/*.md").empty?
      true
    end
  end
end
