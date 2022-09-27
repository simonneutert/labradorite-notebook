# frozen_string_literal: true

module Helper
  class DeepCopy
    class << self
      def create(obj)
        Marshal.load(Marshal.dump(obj))
      end
    end
  end
end
