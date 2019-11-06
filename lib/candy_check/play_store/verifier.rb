module CandyCheck
  module PlayStore
    # Verifies purchase tokens against the Google API.
    # The call return either a {SubscriptionPurchases::SubscriptionPurchase} or a {VerificationFailure}
    class Verifier
      # Initializes a new verifier which is bound to an authorization
      # @param authorization [Google::Auth::ServiceAccountCredentials] to use against the PlayStore API
      def initialize(authorization:)
        @authorization = authorization
      end

      # Contacts the Google API and requests the product state
      # @param package_name [String] to query
      # @param product_id [String] to query
      # @param token [String] to use for authentication
      # @return [ProductPurchases::ProductPurchase] if successful
      # @return [VerificationFailure] otherwise
      def verify_product_purchase(package_name:, product_id:, token:)
        verifier = CandyCheck::PlayStore::ProductPurchases::ProductVerification.new(
          package_name: package_name,
          product_id: product_id,
          token: token,
          authorization: @authorization,
        )
        verifier.call!
      end

      # Contacts the Google API and requests the product state
      # @param package_name [String] to query
      # @param subscription_id [String] to query
      # @param token [String] to use for authentication
      # @return [SubscriptionPurchases::SubscriptionPurchase] if successful
      # @return [VerificationFailure] otherwise
      def verify_subscription_purchase(package_name:, subscription_id:, token:)
        verifier = CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionVerification.new(
          package_name: package_name,
          subscription_id: subscription_id,
          token: token,
          authorization: @authorization,
        )
        verifier.call!
      end
    end
  end
end
