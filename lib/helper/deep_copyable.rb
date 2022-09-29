# frozen_string_literal: true

module Helper
  module DeepCopyable
    def create(obj)
      Marshal.load(Marshal.dump(obj))
    end
  end
end
