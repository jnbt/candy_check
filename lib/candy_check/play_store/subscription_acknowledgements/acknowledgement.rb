module CandyCheck
  module PlayStore
    module SubscriptionAcknowledgements
      # Acknowledges a subscription through the API

      class Acknowledgement
        # @return [String] the package_name which will be queried
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

        def call!
          acknowledge!

          CandyCheck::PlayStore::SubscriptionAcknowledgements::Response.new(
            result: @response[:result], error_data: @response[:error_data])
        end

        private

        def acknowledge!
          service = CandyCheck::PlayStore::AndroidPublisherService.new

          service.authorization = @authorization
          service.acknowledge_purchase_subscription(package_name, subscription_id, token) do |result, error_data|
            @response = { result: result, error_data: error_data }
          end
        end
      end
    end
  end
end
