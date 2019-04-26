module CandyCheck
  module PlayStore
    module ProductPurchases
      # Verifies a purchase token against the Google API
      # The call return either an {Receipt} or an {VerificationFailure}
      class ProductVerification
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
        def initialize(client, package, product_id, token)
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
            CandyCheck::PlayStore::ProductPurchases::ProductPurchase.new(@response)
          else
            CandyCheck::PlayStore::VerificationFailure.new(@response["error"])
          end
        end

        private

        def valid?
          @response && @response["purchaseState"] && @response["consumptionState"]
        end

        def verify!
          args = {
            "packageName" => package,
            "productId" => product_id,
            "token" => token,
          }
          @response = Google::Apis::AndroidpublisherV3::ProductPurchase.new(args)
        end
      end
    end
  end
end
