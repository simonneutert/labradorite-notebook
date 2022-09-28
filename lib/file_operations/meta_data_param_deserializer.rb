# frozen_string_literal: true

module FileOperations
  class MetaDataParamDeserializer
    URLS_REGEXP = %r{\S+://\S*}i
    class << self
      def read(params)
        data = Marshal.load(Marshal.dump(params))
        content = data['content']
        data = data.slice('tags', 'title')
        data['tags'] = data['tags'].split(',').map(&:strip).join(',')
        data['urls'] = content.scan(URLS_REGEXP).map do |url|
          markdown_url_escape(url)
        end
        data
      end

      private

      def markdown_url_escape(url)
        return url unless url.start_with?('[')

        begin
          url.split('](').last.split(')').first
        rescue StandardError => e
          puts e
          url
        end
      end
    end
  end
end
