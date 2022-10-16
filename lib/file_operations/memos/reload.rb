module Controllers
  module Memos
    class Reload
      def initialize(index)
        @index = index
      end

      def recreate_index
        SearchIndex::Core.new(@index).recreate_index!
      end

      def status
        { status: :success }
      end
    end
  end
end
