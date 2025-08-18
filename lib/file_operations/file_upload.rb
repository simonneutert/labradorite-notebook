# frozen_string_literal: true

require_relative '../helper/app_logger'

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
      process_file_upload
    rescue StandardError => e
      handle_upload_error(e)
    end

    def status
      return { success: @success } if @success

      { success: false, error: @error.to_s }
    end

    private

    # Processes the main file upload operation
    def process_file_upload
      filename = prepare_filename
      validate!(filename)

      pathy_filename = generate_safe_filename(filename)
      file_content = read_uploaded_file

      write_file_to_disk(pathy_filename, file_content)
      @success = "#{@params_path}/#{pathy_filename}"
    end

    # Handles different types of upload errors with appropriate logging
    def handle_upload_error(error)
      case error
      when ArgumentError
        Helper::AppLogger.warn("File upload validation failed: #{error.message}")
      when Errno::ENOENT
        Helper::AppLogger.error("File upload failed - file not found: #{error.message}")
      when Errno::EACCES
        Helper::AppLogger.error("File upload failed - permission denied: #{error.message}")
      else
        Helper::AppLogger.error("File upload failed: #{error.message}")
      end
      @error = error
    end

    # Prepares filename with proper encoding
    def prepare_filename
      @params_file_data[:filename].encode('utf-8', invalid: :replace, undef: :replace, replace: '_')
    end

    # Generates a safe filename for storage
    def generate_safe_filename(filename)
      # dropping the first character to avoid leading slash
      "#{Time.now.to_i}-#{filename}"[1..].tr('/', '_').tr(' ', '_')
    end

    # Reads content from the uploaded temporary file
    def read_uploaded_file
      File.read(@params_file_data[:tempfile])
    end

    # Writes file content to the target location
    def write_file_to_disk(filename, content)
      File.write("#{@root_path}#{@params_path}/#{filename}", content, mode: 'wb')
    end

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
