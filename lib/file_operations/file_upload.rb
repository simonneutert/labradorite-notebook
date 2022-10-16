module FileOperations
  class FileUpload
    include Helper::DeepCopyable

    def initialize(root_path, params)
      @root_path = root_path
      @params = params
      @params_file_data = @params['file']
      @params_path = @params['path']
    end

    def store
      filename = @params_file_data[:filename]
      validate!(filename)

      pathy_filename = "#{Time.now.to_i}-#{filename}"[1..-1].gsub('/', '_')
      file_content = File.read(@params_file_data[:tempfile])

      File.write("#{@root_path}#{@params_path}/#{pathy_filename}",
                 file_content,
                 mode: 'wb')
      @success = "#{@params_path}/#{pathy_filename}"
    rescue StandardError => e
      @error = e
    end

    def status
      return { success: @success } if @success

      { success: false, error: "#{@error}" }
    end

    private

    def mime_type_whitelisted?(filename_downcased)
      MEDIA_WHITELIST.any? { |t| filename_downcased.end_with?(t.downcase) }
    end

    def filename_reserved?(filename_downcased)
      ['memo.md', 'memo.yaml', 'memo.yml'].any? { |name| filename_downcased.end_with?(name) }
    end

    def validate!(filename)
      filename_downcased = filename.downcase
      validate_mime_type!(filename_downcased)
      validate_reserved_filenames!(filename_downcased)
    end

    def validate_mime_type!(filename_downcased)
      raise 'Media Type not supported!' unless mime_type_whitelisted?(filename_downcased)
    end

    def validate_reserved_filenames!(filename_downcased)
      raise 'Filename forbidden!' if filename_reserved?(filename_downcased)
    end
  end
end
