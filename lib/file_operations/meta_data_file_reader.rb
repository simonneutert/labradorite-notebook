# frozen_string_literal: true

module FileOperations
  class MetaDataFileReader
    class << self
      def from_path(path_string)
        to_yaml(File.read(path_string))
      end

      def hash_to_struct(meta_data)
        MetaStruct.new(
          meta_data['id'],
          meta_data['title'],
          meta_data['tags'],
          meta_data['urls'],
          meta_data['updated_at']
        )
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
