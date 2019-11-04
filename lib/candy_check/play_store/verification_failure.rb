module CandyCheck
  module PlayStore
    # Represents a failing call against the Google API server
    class VerificationFailure
      include Utils::AttributeReader

      # @return [Hash] the raw attributes returned from the server
      attr_reader :error

      # Initializes a new instance which bases on a JSON result
      # from Google API servers
      # @param error [Hash]
      def initialize(error)
        @error = error
      end

      # The code of the failure
      # @return [Fixnum]
      def code
        Integer(error.status_code)
      rescue
        -1
      end

      # The message of the failure
      # @return [String]
      def message
        error.message || "Unknown error"
      end
    end
  end
end
