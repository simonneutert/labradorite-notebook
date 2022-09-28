# frozen_string_literal: true

module SearchIndex
  attr_reader :dev

  class Core
    def initialize(index)
      @index = index
      @dev = ENV['RACK_ENV'] == 'development'
    end

    def recreate_index!
      puts 'REMOVED INDEX' if FileUtils.rm_rf('.tantiny')

      @index = Tantiny::Index.new '.tantiny', exclusive_writer: @dev do
        id :id
        text :tags
        text :title
        text :content
        date :updated_at
      end

      notebook_entry_data = Dir.glob('memos/**/*.md').map do |file|
        meta = YAML.load(File.read(file.gsub('memo.md', 'meta.yaml')))
        content = File.read(file)
        data = meta.merge({ 'content' => content })
        map_data_to_schema(data)
      end

      @index.transaction do
        notebook_entry_data.each do |data_schema|
          @index << data_schema
        end
      end

      @index.reload
      @index
    end

    private

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
