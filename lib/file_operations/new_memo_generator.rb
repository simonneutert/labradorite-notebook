module FileOperations
  class NewMemoGenerator
    attr_reader :slug, :path

    def initialize; end

    def generate
      @slug = Helper::SimpleUidGenerator.generate
      d = DateTime.now
      @path = "memos/#{d.year}/#{d.month}/#{d.day}/#{@slug}"
      raise ArgumentError if File.exist?(@path)

      FileUtils.mkdir_p(@path)

      File.write("#{@path}/memo.md", '')
      File.write("#{@path}/meta.yaml",
                 { 'id' => "#{d.year}/#{d.month}/#{d.day}/#{@slug}",
                   'title' => @slug,
                   'tags' => '',
                   'urls' => [],
                   'updated_at' => d }.to_yaml.to_s)
      @path
    end
  end
end
