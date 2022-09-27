# frozen_string_literal: true

module FileOperations
  class MetaDataParamDeserializer
    URLS_REGEXP = %r{\w+://\S*}i
    class << self
      def read(params)
        data = Marshal.load(Marshal.dump(params))
        content = data['content']
        data = data.slice('tags', 'title')
        data['tags'] = data['tags'].split(',').map(&:strip)
        data['urls'] = content.scan(URLS_REGEXP)
        data
      end
    end
  end
end
