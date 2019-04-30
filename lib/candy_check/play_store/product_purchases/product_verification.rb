module CandyCheck
  module PlayStore
    module ProductPurchases
      # Verifies a purchase token against the Google API
      # The call return either an {Receipt} or an {VerificationFailure}
      class ProductVerification
        include CandyCheck::PlayStore::AndroidPublisherService
        # @return [String] the package which will be queried
        attr_reader :package
        # @return [String] the item id which will be queried
        attr_reader :product_id
        # @return [String] the token for authentication
        attr_reader :token

        # Initializes a new call to the API
        # @param package [String]
        # @param product_id [String]
        # @param token [String]
        def initialize(package, product_id, token)
          @package = package
          @product_id = product_id
          @token = token
        end

        # Performs the verification against the remote server
        # @return [Receipt] if successful
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
          service = android_publisher_service
          service.get_purchase_product(package, product_id, token) do |result, error|
            @response = { result: result, error: error }
          end
        end
      end
    end
  end
end
