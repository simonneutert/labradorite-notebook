module Controllers
  module Memos
    class Reload
      def initialize(index)
        @index = index
      end

      #
      # recreates the index
      #
      # @return [Tantiny::Index]
      #
      def recreate_index
        SearchIndex::Core.new(@index).recreate_index!
      end

      def status
        { status: :success }
      end
    end
  end
end
