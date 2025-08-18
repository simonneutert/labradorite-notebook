# frozen_string_literal: true

module SearchIndex
  # Builds FTS5 queries for SQLite full-text search
  #
  # This class encapsulates the logic for constructing FTS5 query strings
  # with support for multi-field searches, exact matches, and prefix matching.
  #
  # @example Basic usage
  #   builder = FtsQueryBuilder.new
  #   query = builder.build_field_query(['title', 'content'], 'search term')
  #   # => "(title:search OR title:search* OR content:search OR content:search*) AND
  #        (title:term OR title:term* OR content:term OR content:term*)"
  #
  # @example Single field search
  #   query = builder.build_field_query(['title'], 'ruby programming')
  #   # => "(title:ruby OR title:ruby*) AND (title:programming OR title:programming*)"
  class FtsQueryBuilder
    # Builds an FTS5 query for searching across specific fields
    #
    # Creates a query that searches for all terms across the specified fields,
    # using both exact matches and prefix matches for better search flexibility.
    #
    # @param fields [Array<String>] fields to search in (e.g., ['title', 'content'])
    # @param query [String] the search query with one or more terms
    # @return [String] the FTS5 query string
    # @raise [ArgumentError] if fields is empty or query is blank
    #
    # @example Multi-term search
    #   build_field_query(['title', 'tags'], 'ruby web framework')
    #   # Returns: "(title:ruby OR title:ruby* OR tags:ruby OR tags:ruby*) AND
    #             (title:web OR title:web* OR tags:web OR tags:web*) AND
    #             (title:framework OR title:framework* OR tags:framework OR tags:framework*)"
    def build_field_query(fields, query)
      validate_inputs(fields, query)

      sanitized_query = sanitize_query(query)
      terms = extract_terms(sanitized_query)

      return '' if terms.empty?

      build_and_query(fields, terms)
    end

    # Builds a simple FTS5 query that searches across all indexed fields
    #
    # This creates a more general query suitable for the main FTS table
    # without field-specific targeting.
    #
    # @param query [String] the search query
    # @return [String] the FTS5 query string
    # @raise [ArgumentError] if query is blank
    #
    # @example General search
    #   build_general_query('ruby programming')
    #   # Returns: 'ruby* AND programming*'
    def build_general_query(query)
      raise ArgumentError, 'Query cannot be blank' if query.nil? || query.strip.empty?

      sanitized_query = sanitize_query(query)
      terms = extract_terms(sanitized_query)

      return '' if terms.empty?

      # For general queries, use prefix matching for better recall
      terms.map { |term| "#{term}*" }.join(' AND ')
    end

    private

    # Validates input parameters
    #
    # @param fields [Array<String>] the fields array to validate
    # @param query [String] the query string to validate
    # @raise [ArgumentError] if validation fails
    def validate_inputs(fields, query)
      raise ArgumentError, 'Fields cannot be empty' if fields.nil? || fields.empty?
      raise ArgumentError, 'Query cannot be blank' if query.nil? || query.strip.empty?
    end

    # Sanitizes the query string by removing potentially problematic characters
    #
    # @param query [String] the raw query string
    # @return [String] the sanitized query string
    def sanitize_query(query)
      # Remove quotes and other FTS5 special characters that could break the query
      query.gsub(/['"]/, '').gsub(/[(){}\[\]]/, '')
    end

    # Extracts individual search terms from the query
    #
    # @param query [String] the sanitized query string
    # @return [Array<String>] array of non-empty terms
    def extract_terms(query)
      query.split(/\s+/).map(&:strip).reject(&:empty?)
    end

    # Builds the main AND query structure
    #
    # Each term must match at least one field (OR within term),
    # and all terms must be present (AND between terms).
    #
    # @param fields [Array<String>] fields to search in
    # @param terms [Array<String>] search terms
    # @return [String] the complete FTS5 query
    def build_and_query(fields, terms)
      term_queries = terms.map { |term| build_term_query(fields, term) }
      term_queries.join(' AND ')
    end

    # Builds a query for a single term across multiple fields
    #
    # For each term, creates both exact and prefix matches across all fields,
    # joined with OR to allow matching in any field.
    #
    # @param fields [Array<String>] fields to search in
    # @param term [String] the search term
    # @return [String] the OR query for this term across all fields
    def build_term_query(fields, term)
      # Create both exact and prefix matches for better search flexibility
      exact_matches = fields.map { |field| "#{field}:#{term}" }
      prefix_matches = fields.map { |field| "#{field}:#{term}*" }

      # Combine exact and prefix matches with OR
      all_matches = exact_matches + prefix_matches
      "(#{all_matches.join(' OR ')})"
    end
  end
end
