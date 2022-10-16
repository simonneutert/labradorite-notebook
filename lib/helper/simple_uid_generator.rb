# frozen_string_literal: true

module Helper
  class SimpleUidGenerator
    class << self
      def generate
        8.times.map do
          ('a'..'z').to_a.sample
        end.join('').insert(4, '-')
      end
    end
  end
end
