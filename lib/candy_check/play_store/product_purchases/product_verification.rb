module CandyCheck
  module PlayStore
    module ProductPurchases
      # Verifies a purchase token against the PlayStore API
      # The call return either a {ProductPurchase} or a {VerificationFailure}
      class ProductVerification
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

        # Performs the verification against the remote server
        # @return [ProductPurchase] if successful
        # @return [VerificationFailure] otherwise
        def call!
          verify!
          if valid?
            CandyCheck::PlayStore::ProductPurchases::ProductPurchase.new(@response[:result])
          else
            CandyCheck::PlayStore::VerificationFailure.new(@response[:error])
          end
        end

        private

        def valid?
          @response[:result] && @response[:result].purchase_state && @response[:result].consumption_state
        end

        def verify!
          service = CandyCheck::PlayStore::AndroidPublisherService.new
          service.authorization = @authorization
          service.get_purchase_product(package_name, product_id, token) do |result, error|
            @response = { result: result, error: error }
          end
        end
      end
    end
  end
end
