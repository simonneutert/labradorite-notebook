# frozen_string_literal: true

module FileOperations
  class MetaDataFileReader
    class << self
      def from_path(path_string)
        to_yaml(File.read(path_string))
      end

      def hash_to_ostruct(meta_data)
        OpenStruct.new(meta_data)
      end

      #
      # returns a hash parsed from a strong representing yaml
      #
      # @param [String] s containing yaml data
      #
      # @return [Hash]
      #
      def to_yaml(str)
        YAML.safe_load(str, permitted_classes: [Date, Time, DateTime])
      end
    end
  end
end
