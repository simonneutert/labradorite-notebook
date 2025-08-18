# frozen_string_literal: true

require_relative '../../search_index/database'

module Controllers
  module System
    # Controller for exposing database connection status and monitoring
    #
    # This controller provides endpoints for monitoring database health,
    # connection statistics, and overall system status.
    #
    # @example Usage in routes
    #   controller = Controllers::System::DatabaseStatus.new
    #   controller.status
    class DatabaseStatus
      # Returns database connection status and statistics
      #
      # @return [Hash] database status information including:
      #   - connection health
      #   - operation statistics
      #   - configuration details
      #   - connection summary
      def status
        database_info = SearchIndex::Database.shared.database_info
        connection_summary = SearchIndex::Database.connection_summary

        {
          status: 'ok',
          timestamp: Time.now.iso8601,
          database: database_info,
          connection_pool: connection_summary,
          health_check: perform_health_check
        }
      rescue StandardError => e
        {
          status: 'error',
          timestamp: Time.now.iso8601,
          error: e.message,
          database: { connected: false },
          connection_pool: { status: 'unavailable' }
        }
      end

      private

      # Performs a quick health check by executing a simple query
      #
      # @return [Hash] health check results
      def perform_health_check
        start_time = Time.now

        begin
          count = SearchIndex::Database.shared.count

          {
            success: true,
            response_time_ms: elapsed_time_ms(start_time),
            record_count: count
          }
        rescue StandardError => e
          {
            success: false,
            response_time_ms: elapsed_time_ms(start_time),
            error: e.message
          }
        end
      end

      # Calculates elapsed time in milliseconds from a start time
      #
      # @param start_time [Time] the starting time
      # @return [Float] elapsed time in milliseconds, rounded to 2 decimal places
      def elapsed_time_ms(start_time)
        ((Time.now - start_time) * 1000).round(2)
      end
    end
  end
end
