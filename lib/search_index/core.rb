# frozen_string_literal: true

module SearchIndex
  attr_reader :dev

  class Core
    MARKDOWN_DIR = 'memos/**/*.md'
    MARKDOWN_FILENAME = 'memo.md'
    META_FILENAME = 'meta.yaml'

    # class methods are simply a global initializer
    class << self
      #
      # initializes the index and sets the schema
      #
      # @return [Tantiny::Index]
      #
      def init_index
        dev = ENV['RACK_ENV'] == 'development'
        # using exclusive_writer break hot reloading in development
        Tantiny::Index.new '.tantiny', exclusive_writer: !dev do
          id :id
          text :tags
          text :title
          text :content
          date :updated_at
        end
      end
    end

    def initialize(index)
      @index = index
      @dev = ENV['RACK_ENV'] == 'development'
    end

    def recreate_index!
      # remove the files from filesystem in order to be able to start from scratch
      puts 'REMOVED INDEX' if FileUtils.rm_rf('.tantiny')
      @index = SearchIndex::Core.init_index
      # extract
      notebook_entry_data = extract_data_from_files
      # upsert
      @index.transaction do
        notebook_entry_data.each do |data_schema|
          @index << data_schema
        end
      end
      # reload and return
      @index.reload
      @index
    end

    private

    # TODO: extract paths to constants
    def extract_data_from_files
      Dir.glob(MARKDOWN_DIR).map do |file|
        meta = YAML.load(File.read(file.gsub(MARKDOWN_FILENAME, META_FILENAME)))
        content = File.read(file)
        data = meta.merge({ 'content' => content })
        map_data_to_schema(data)
      end
    end

    def map_data_to_schema(data_hsh)
      # use SearchIndex::Schema later
      {
        id: data_hsh['id'],
        tags: data_hsh['tags'],
        title: data_hsh['title'].strip,
        content: data_hsh['content'],
        updated_at: DateTime.now
      }
    end
  end
end
