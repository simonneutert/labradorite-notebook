# frozen_string_literal: true

module Controllers
  module Memos
    class Search
      attr_reader :r, :meta, :meta_struct, :index

      def initialize(req, index)
        @params = Helper::DeepCopy.create(req.params)
        @index = index
        @search_input = @params['search']
      end

      def run(limit: 100)
        content_search = @index.smart_query(:content, @search_input)
        title_search = @index.smart_query(:title, @search_input)
        tag_search = @index.smart_query(:tags, @search_input)
        search_results = @index.search(title_search | tag_search | content_search, limit: limit)

        build_results(search_results)
      end

      private

      def build_results(search_results)
        search_results.map do |path_to_memo_md|
          path = "/memos/#{path_to_memo_md}"
          url = path.dup
          path_to_memo_md_file = ".#{path}/memo.md"
          path_to_memo_meta_yaml_file = ".#{path}/meta.yaml"
          read_meta_file(path_to_memo_meta_yaml_file)
          read_markdown_file(path_to_memo_md_file)

          result_triplet(url, @meta_struct.title, @markdown_content)
        end
      end

      def read_markdown_file(path_to_memo_md_file)
        @markdown_content = File.read(path_to_memo_md_file)
                                .scan(/^.*#{@search_input}.*$/i)
      end

      def read_meta_file(path_to_memo_meta_yaml)
        @meta = FileOperations::MetaDataFileReader.from_path(path_to_memo_meta_yaml)
        @meta_struct = FileOperations::MetaDataFileReader.hash_to_struct(@meta)
      end

      #
      # returns a triplet of search result data
      #
      # @param [String] url
      # @param [String] title of memo/note
      # @param [String] content with the search match text line
      #
      # @return [Array<String>]
      #
      def result_triplet(url, title, content)
        [url, title, content]
      end
    end
  end
end
