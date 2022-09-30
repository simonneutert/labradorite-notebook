# frozen_string_literal: true

module FileOperations
  class MetaDataFileReader
    class << self
      def from_path(path_string)
        to_yaml(File.read(path_string))
      end

      def to_ostruct(meta_data)
        OpenStruct.new(meta_data)
      end

      #
      # returns a hash parsed from a strong representing yaml
      #
      # @param [String] s containing yaml data
      #
      # @return [Hash]
      #
      def to_yaml(s)
        YAML.safe_load(s, [Date, Time, DateTime], symbolize_names: false)
      end
    end
  end
end
