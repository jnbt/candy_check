module CandyCheck
  module PlayStore
    # Verifies purchase tokens against the Google API.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Verifier
      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param product_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def verify(package, product_id, token)
        v = CandyCheck::PlayStore::ProductPurchases::ProductVerification
        verifier = v.new(package, product_id, token)
        verifier.call!
      end

      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param subscription_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def verify_subscription(package, subscription_id, token)
        v = CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionVerification
        verifier = v.new(package, subscription_id, token)
        verifier.call!
      end
    end
  end
end
