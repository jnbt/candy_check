module CandyCheck
  module AppStore
    # Verifies receipts against the verification servers.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Verifier
      # HTTPS endpoint for production receipts
      PRODUCTION_ENDPOINT = 'https://buy.itunes.apple.com/verifyReceipt'.freeze
      # HTTPS endpoint for sandbox receipts
      SANDBOX_ENDPOINT = 'https://sandbox.itunes.apple.com/verifyReceipt'.freeze
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
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def verify(receipt_data, secret = nil)
        @verifier = Verification
        fetch_receipt_information(receipt_data, secret)
      end

      # Calls a subscription verification for the given input
      # @param receipt_data [String] the raw data to be verified
      # @param secret [string] the optional shared secret
      # @return [ReceiptCollection] if successful
      # @return [Verification] otherwise
      def verify_subscription(receipt_data, secret = nil)
        @verifier = SubscriptionVerification
        fetch_receipt_information(receipt_data, secret)
      end

      # Calls a verification for the given receipt data which presents in
      # ios7 style grand unified format
      # @param receipt_data [String] the raw data to be verified
      # @param secret [string] the optional shared secret
      # @return [Unified::VerifiedResponse] if successful
      # @return [VerificationFailure] otherwise
      def verify_unified(receipt_data, secret = nil)
        @verifier = Unified::Verification
        fetch_receipt_information(receipt_data, secret)
      end

      private

      def fetch_receipt_information(receipt_data, secret = nil)
        default_endpoint, opposite_endpoint = endpoints
        result = call_for(default_endpoint, receipt_data, secret)
        if should_retry?(result)
          return call_for(opposite_endpoint, receipt_data, secret)
        end
        result
      end

      def call_for(endpoint_url, receipt_data, secret)
        @verifier.new(endpoint_url, receipt_data, secret).call!
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
        if config.production?
          REDIRECT_TO_SANDBOX_CODE
        else
          REDIRECT_TO_PRODUCTION_CODE
        end
      end

      def redirect?(failure)
        failure.code == redirect_code
      end
    end
  end
end
