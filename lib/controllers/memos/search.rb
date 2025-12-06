# frozen_string_literal: true

require_relative '../../helper/memo_path'
require_relative '../../config/constants'

module Controllers
  module Memos
    # Controller for handling memo search requests
    #
    # Processes search queries from web requests and returns formatted results
    # using the configured search index.
    #
    # @example Usage in a Roda route
    #   r.post 'search' do
    #     Controllers::Memos::Search.new(r, index).run
    #   end
    class Search
      attr_reader :r, :meta, :meta_struct, :index

      # Creates a new search controller
      #
      # @param req [Roda::RodaRequest] the web request object
      # @param index [SearchIndex::SqliteCore] the search index to query
      def initialize(req, index)
        @params = Helper::DeepCopy.create(req.params)
        @index = index
        @search_input = @params['search'] || @params['q']
      end

      # Executes the search and returns results
      #
      # @param limit [Integer] maximum number of results to return
      # @return [Array<Array>] array of [url, title, snippet] result arrays
      def run(limit: Config::Constants::Search::DEFAULT_SEARCH_LIMIT)
        @index.search(@search_input, limit: limit)
      end
    end
  end
end
