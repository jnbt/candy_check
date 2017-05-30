# frozen_string_literal: true
module CandyCheck
  module PlayStore
    # Represents a failing call against the Google API server
    class VerificationFailure
      include Utils::AttributeReader

      # @return [Hash] the raw attributes returned from the server
      attr_reader :attributes

      # Initializes a new instance which bases on a JSON result
      # from Google API servers
      # @param attributes [Hash]
      def initialize(attributes)
        @attributes = attributes || {}
      end

      # The code of the failure
      # @return [Fixnum]
      def code
        read('code') || -1
      end

      # The message of the failure
      # @return [String]
      def message
        read('message') || 'Unknown error'
      end
    end
  end
end
