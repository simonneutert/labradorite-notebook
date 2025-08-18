# frozen_string_literal: true

module Controllers
  module Memos
    class Reload
      def initialize(index)
        @index = index
      end

      #
      # Recreates the search index by rebuilding it from memo files
      #
      # @return [SearchIndex::SqliteCore] The rebuilt search index
      #
      def recreate_index
        @index.recreate_index!
      end

      def status
        { status: :success }
      end
    end
  end
end
