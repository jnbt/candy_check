module CandyCheck
  module PlayStore
    module SubscriptionPurchases
      # Verifies a purchase token against the Google API
      # The call return either an {Receipt} or an {VerificationFailure}
      class SubscriptionVerification
        # @return [String] the package which will be queried
        attr_reader :package
        # @return [String] the item id which will be queried
        attr_reader :subscription_id
        # @return [String] the token for authentication
        attr_reader :token

        # Initializes a new call to the API
        # @param package [String]
        # @param subscription_id [String]
        # @param token [String]
        def initialize(client, package, subscription_id, token)
          @package = package
          @subscription_id = subscription_id
          @token = token
        end

        # Performs the verification against the remote server
        # @return [Subscription] if successful
        # @return [VerificationFailure] otherwise
        def call!
          verify!
          if valid?
            CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase.new(@response)
          else
            CandyCheck::PlayStore::VerificationFailure.new(@response["error"])
          end
        end

        private

        def valid?
          ok_kind = @response["kind"] == "androidpublisher#subscriptionPurchase"
          @response && @response["expiryTimeMillis"] && ok_kind
        end

        def verify!
          parameters = {
            "packageName" => package,
            "subscriptionId" => subscription_id,
            "token" => token,
          }
          @response = Google::Apis::AndroidpublisherV3::SubscriptionPurchase.new(args)
        end
      end
    end
  end
end
