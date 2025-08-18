# frozen_string_literal: true

require_relative '../helper/app_logger'

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
        return url unless markdown_style_url?(url)

        begin
          url.split('](').last.split(')').first
        rescue StandardError => e
          Helper::AppLogger.error("Failed to parse markdown URL: #{e.message}")
          url
        end
      end

      def markdown_style_url?(url)
        url.include?('](') && url.end_with?(')')
      end
    end
  end
end
