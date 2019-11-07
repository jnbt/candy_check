module CandyCheck
  module PlayStore
    module SubscriptionPurchases
      # Verifies a purchase token against the Google API
      # The call return either an {SubscriptionPurchase} or an {VerificationFailure}
      class SubscriptionVerification
        # @return [String] the package which will be queried
        attr_reader :package_name
        # @return [String] the item id which will be queried
        attr_reader :subscription_id
        # @return [String] the token for authentication
        attr_reader :token

        # Initializes a new call to the API
        # @param package_name [String]
        # @param subscription_id [String]
        # @param token [String]
        def initialize(package_name:, subscription_id:, token:, authorization:)
          @package_name = package_name
          @subscription_id = subscription_id
          @token = token
          @authorization = authorization
        end

        # Performs the verification against the remote server
        # @return [SubscriptionPurchase] if successful
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
          service = CandyCheck::PlayStore::AndroidPublisherService.new
          service.authorization = @authorization
          service.get_purchase_subscription(package_name, subscription_id, token) do |result, error|
            @response = { result: result, error: error }
          end
        end
      end
    end
  end
end
