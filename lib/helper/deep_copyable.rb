# frozen_string_literal: true

module Helper
  module DeepCopyable
    def deep_copy(obj)
      Marshal.load(Marshal.dump(obj))
    end
  end
end
