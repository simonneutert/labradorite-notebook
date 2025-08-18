# frozen_string_literal: true

require 'logger'

module Helper
  # Centralized logging utility with configurable log levels and formatting
  #
  # @example Basic usage
  #   Helper::AppLogger.info("Application started")
  #   Helper::AppLogger.error("Failed to process request")
  #
  # @example Configure log level via environment
  #   ENV['LOG_LEVEL'] = 'DEBUG'  # Will show all log levels
  #   ENV['LOG_LEVEL'] = 'ERROR'  # Will only show errors
  class AppLogger
    class << self
      # Gets the shared logger instance
      #
      # @return [Logger] the configured logger instance
      def logger
        @logger ||= create_logger
      end

      # Logs an informational message
      #
      # @param message [String] the message to log
      # @return [void]
      def info(message)
        logger.info(message)
      end

      # Logs a warning message
      #
      # @param message [String] the message to log
      # @return [void]
      def warn(message)
        logger.warn(message)
      end

      # Logs an error message
      #
      # @param message [String] the message to log
      # @return [void]
      def error(message)
        logger.error(message)
      end

      # Logs a debug message
      #
      # @param message [String] the message to log
      # @return [void]
      def debug(message)
        logger.debug(message)
      end

      private

      def create_logger
        logger = Logger.new($stdout)
        logger.level = log_level
        logger.formatter = log_formatter
        logger
      end

      def log_level
        case ENV['LOG_LEVEL']&.upcase
        when 'DEBUG'
          Logger::DEBUG
        when 'INFO'
          Logger::INFO
        when 'WARN'
          Logger::WARN
        when 'ERROR'
          Logger::ERROR
        else
          # Default to INFO in production, DEBUG in development/test
          ENV['RACK_ENV'] == 'production' ? Logger::INFO : Logger::DEBUG
        end
      end

      def log_formatter
        proc do |severity, datetime, _progname, msg|
          timestamp = datetime.strftime('%Y-%m-%d %H:%M:%S')
          "[#{timestamp}] #{severity}: #{msg}\n"
        end
      end
    end
  end
end
