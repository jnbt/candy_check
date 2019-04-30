module CandyCheck
  module PlayStore
    module SubscriptionPurchases
      # Verifies a purchase token against the Google API
      # The call return either an {Receipt} or an {VerificationFailure}
      class SubscriptionVerification
        include CandyCheck::PlayStore::AndroidPublisherService
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
        def initialize(package, subscription_id, token)
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
            CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase.new(@response[:result])
          else
            CandyCheck::PlayStore::VerificationFailure.new(@response[:error])
          end
        end

        private

        def valid?
          return false unless @response[:result]
          ok_kind = @response[:result].kind == "androidpublisher#subscriptionPurchase"
          @response && @response[:result].expiry_time_millis && ok_kind
        end

        def verify!
          service = android_publisher_service
          service.get_purchase_subscription(package, subscription_id, token) do |result, error|
            @response = { result: result, error: error }
          end
        end
      end
    end
  end
end
