# frozen_string_literal: true

require_relative '../helper/memo_path'

module FileOperations
  # Generates new memo files with unique identifiers and proper directory structure
  #
  # Creates both the markdown content file and YAML metadata file for a new memo,
  # organizing them in a date-based directory hierarchy with unique slugs.
  #
  # @example Create a new memo
  #   generator = FileOperations::NewMemoGenerator.new
  #   memo_path = generator.generate
  #   puts generator.title  # => "2024-01-15 - New Memo abcd-efgh"
  #   puts memo_path        # => "memos/2024/01/15/abcd-efgh"
  class NewMemoGenerator
    attr_reader :slug, :title, :path

    def initialize
      # overwrite this, if needed
    end

    # Generates a new memo with a unique slug, title, and path.
    #
    # @raise [ArgumentError] if the memo already exists.
    # @return [String] The path of the newly generated memo.
    def generate
      datetime_now = DateTime.now
      @slug = Helper::SimpleUidGenerator.generate
      @title = generate_title(datetime_now)
      @path = "memos/#{path_id(datetime_now, @slug)}"
      raise ArgumentError if File.exist?(@path)

      FileUtils.mkdir_p(@path)
      File.write("#{@path}/#{Helper::MemoPath::MEMO_FILENAME}", '')
      File.write("#{@path}/#{Helper::MemoPath::META_FILENAME}", meta_yaml(datetime_now, @title, @slug))
      @path
    end

    private

    # Generates a title for a new memo based on the current datetime and a slug.
    #
    # @param datetime_now [DateTime] The current datetime.
    # @param slug [String] The slug to be included in the title.
    # @return [String] The generated title.
    def generate_title(datetime_now, slug = nil)
      month = datetime_now.month.to_s.rjust(2, '0')
      day = datetime_now.day.to_s.rjust(2, '0')
      if slug.nil? || slug.empty?
        "#{datetime_now.year}-#{month}-#{day}"
      else
        "#{datetime_now.year}-#{month}-#{day}-#{slug}"
      end
    end

    # Generates a path ID based on the current datetime and a slug.
    #
    # @param datetime_now [DateTime] the current datetime
    # @param slug [String] the slug used in the path ID
    # @return [String] the generated path ID
    def path_id(datetime_now, slug)
      "#{datetime_now.year}/#{datetime_now.month}/#{datetime_now.day}/#{slug}"
    end

    # Generates a YAML string representing the metadata for a new memo.
    #
    # @param datetime_now [DateTime] The current date and time.
    # @param title [String] The title of the memo.
    # @return [String] The YAML string representing the metadata.
    def meta_yaml(datetime_now, title, slug)
      {
        'id' => path_id(datetime_now, slug),
        'title' => title,
        'tags' => '',
        'urls' => [],
        'updated_at' => datetime_now
      }.to_yaml.to_s
    end
  end
end
