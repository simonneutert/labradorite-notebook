module Controllers
  module Memos
    class Search
      attr_reader :r, :meta, :meta_ostruct, :index

      def initialize(r, index)
        @params = Helper::DeepCopy.create(r.params)
        @index = index
        @search_input = @params['search']
      end

      def run
        content_search = @index.smart_query(:content, @search_input)
        title_search = @index.smart_query(:title, @search_input)
        tag_search = @index.smart_query(:tags, @search_input)
        search_results = @index.search(title_search | tag_search | content_search)

        search_results.map do |path_to_memo_md|
          url = "/memos/#{path_to_memo_md}"
          path_to_memo_md_file = "./memos/#{path_to_memo_md}/memo.md"
          path_to_memo_meta_yaml_file = "./memos/#{path_to_memo_md}/meta.yaml"
          read_meta_file(path_to_memo_meta_yaml_file)
          read_markdown_file(path_to_memo_md_file)

          result_triplet(url, @meta_ostruct.title, @markdown_content)
        end
      end

      private

      def read_markdown_file(path_to_memo_md_file)
        @markdown_content = File.read(path_to_memo_md_file).scan(/^.*#{@search_input}.*$/i)
      end

      def read_meta_file(path_to_memo_meta_yaml)
        @meta = FileOperations::MetaDataFileReader.from_path(path_to_memo_meta_yaml)
        @meta_ostruct = FileOperations::MetaDataFileReader.to_ostruct(@meta)
      end

      def result_triplet(url, title, content)
        [url, title, content]
      end
    end
  end
end
