module CandyCheck
  module PlayStore
    module ProductAcknowledgements
      # Verifies a purchase token against the PlayStore API

      class Acknowledgement
        # @return [String] the package_name which will be queried
        attr_reader :package_name
        # @return [String] the item id which will be queried
        attr_reader :product_id
        # @return [String] the token for authentication
        attr_reader :token

        # Initializes a new call to the API
        # @param package_name [String]
        # @param product_id [String]
        # @param token [String]
        def initialize(package_name:, product_id:, token:, authorization:)
          @package_name = package_name
          @product_id = product_id
          @token = token
          @authorization = authorization
        end

        def call!
          acknowledge!

          CandyCheck::PlayStore::ProductAcknowledgements::Response.new(
            result: @response[:result], error_data: @response[:error_data])
        end

        private

        def acknowledge!
          service = CandyCheck::PlayStore::AndroidPublisherService.new

          service.authorization = @authorization
          service.acknowledge_purchase_product(package_name, product_id, token) do |result, error_data|
            @response = { result: result, error_data: error_data }
          end
        end
      end
    end
  end
end
