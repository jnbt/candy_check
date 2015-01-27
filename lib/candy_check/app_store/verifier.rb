module CandyCheck
  module AppStore
    # Verifies receipts against the verification servers.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Verifier
      # HTTPS endpoint for production receipts
      PRODUCTION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'
      # HTTPS endpoint for sandbox receipts
      SANDBOX_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'
      # Status code from production endpoint when receiving a sandbox
      # receipt which occurs during the app's review process
      REDIRECT_TO_SANDBOX_CODE = 21_007
      # Status code from the sandbox endpoint when receiving a production
      # receipt
      REDIRECT_TO_PRODUCTION_CODE = 21_008

      # @return [Config] the current configuration
      attr_reader :config

      # Initializes a new verifier for the application which is bound
      # to a configuration
      # @param config [Config]
      def initialize(config)
        @config = config
      end

      # Calls a verification for the given input
      # @param receipt_data [String] the raw data to be verified
      # @param secret [String] the optional shared secret
      # @return [Receipt, VerificationFailure] the result
      def verify(receipt_data, secret = nil)
        default_endpoint, opposite_endpoint = endpoints
        result = call_for(default_endpoint, receipt_data, secret)
        if should_retry?(result)
          return call_for(opposite_endpoint, receipt_data, secret)
        end
        result
      end

      private

      def call_for(endpoint_url, receipt_data, secret)
        Verification.new(endpoint_url, receipt_data, secret).call!
      end

      def should_retry?(result)
        result.is_a?(VerificationFailure) && redirect?(result)
      end

      def endpoints
        if config.production?
          [PRODUCTION_ENDPOINT, SANDBOX_ENDPOINT]
        else
          [SANDBOX_ENDPOINT, PRODUCTION_ENDPOINT]
        end
      end

      def redirect_code
        config.production? ? REDIRECT_TO_SANDBOX_CODE :
                             REDIRECT_TO_PRODUCTION_CODE
      end

      def redirect?(failure)
        failure.code == redirect_code
      end
    end
  end
end
