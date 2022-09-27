# frozen_string_literal: true

module FileOperations
  class MetaDataFileReader
    class << self
      def from_path(path_string)
        YAML.safe_load(File.read(path_string), symbolize_names: false)
      end

      def to_ostruct(meta_data)
        OpenStruct.new(meta_data)
      end
    end
  end
end
