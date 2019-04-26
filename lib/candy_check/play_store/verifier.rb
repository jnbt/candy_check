module CandyCheck
  module PlayStore
    # Verifies purchase tokens against the Google API.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Verifier
      # @return [Config] the current configuration
      attr_reader :config

      # Initializes a new verifier for the application which is bound
      # to a configuration
      # @param config [Config]
      def initialize(config)
        @config = config
      end

      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param product_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def verify(package, product_id, token)
        verification = CandyCheck::PlayStore::ProductPurchases::ProductVerification.new(@client, package, product_id, token)
        verification.call!
      end

      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param subscription_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def verify_subscription(package, subscription_id, token)
        v = CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionVerification.new(
          @client, package, subscription_id, token
        )
        v.call!
      end
    end
  end
end
