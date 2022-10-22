# frozen_string_literal: true

module FileOperations
  #
  # Persists file to disk with a simple API
  #
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

      pathy_filename = "#{Time.now.to_i}-#{filename}"[1..].gsub('/', '_').gsub(' ', '_')
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

      { success: false, error: @error.to_s }
    end

    private

    def mime_type_whitelisted?(filename_downcased)
      MEDIA_WHITELIST.any? { |t| filename_downcased.end_with?(t.downcase) }
    end

    #
    # validates structure of params
    #
    # @param [String] filename
    #
    # @raise [ArgumentError]
    # @return [TrueClass]
    #
    def validate!(filename)
      filename_downcased = filename.downcase
      validate_mime_type!(filename_downcased)
    end

    def validate_mime_type!(filename_downcased)
      raise ArgumentError, 'Media Type not supported!' unless mime_type_whitelisted?(filename_downcased)
    end
  end
end
