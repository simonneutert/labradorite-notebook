module FileOperations
  module Attachments
    class Deleter
      def initialize(root_path, path, filename)
        @root_path = root_path
        @path = path
        @filename = filename
      end

      #
      # deletes the file from path
      #
      # @return [String] deleted file (path)
      #
      def delete
        FileUtils.rm(build_path)
      end

      def status
        { status: :success }
      end

      private

      def build_path
        "#{@root_path}/memos/#{@path}/#{@filename}"
      end
    end
  end
end
