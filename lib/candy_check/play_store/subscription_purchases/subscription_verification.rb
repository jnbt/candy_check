module CandyCheck
  module PlayStore
    module SubscriptionPurchases
      # Verifies a purchase token against the Google API
      # The call return either an {Receipt} or an {VerificationFailure}
      class SubscriptionVerification
        # @return [String] the package which will be queried
        attr_reader :package
        # @return [String] the item id which will be queried
        attr_reader :product_id
        # @return [String] the token for authentication
        attr_reader :token

        # Initializes a new call to the API
        # @param client [Client] a shared client instance
        # @param package [String]
        # @param product_id [String]
        # @param token [String]
        def initialize(client, package, product_id, token)
          @client = client
          @package = package
          @product_id = product_id
          @token = token
        end

        # Performs the verification against the remote server
        # @return [Subscription] if successful
        # @return [VerificationFailure] otherwise
        def call!
          verify!
          if valid?
            CandyCheck::PlayStore::SubscriptionPurchase::Subscription.new(@response)
          else
            VerificationFailure.new(@response["error"])
          end
        end

        private

        def valid?
          ok_kind = @response["kind"] == "androidpublisher#subscriptionPurchase"
          @response && @response["expiryTimeMillis"] && ok_kind
        end

        def verify!
          @response = @client.verify_subscription(package, product_id, token)
        end
      end
    end
  end
end
