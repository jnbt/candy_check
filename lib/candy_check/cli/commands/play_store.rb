module CandyCheck
  module CLI
    module Commands
      # Command to verify an PlayStore purchase
      class PlayStore < Base
        # Prepare a verification run from the terminal
        # @param package_name [String]
        # @param product_id [String]
        # @param token [String]
        # @param options [Hash]
        # @option options [String] :json_key_file to use for API access
        def initialize(package_name, product_id, token, options)
          @package = package_name
          @product_id = product_id
          @token = token
          super(options)
        end

        # Print the result of the verification to the terminal
        def run
          verifier = CandyCheck::PlayStore::Verifier.new(authorization: authorization)
          result = verifier.verify_product_purchase(
            package_name: @package,
            product_id: @product_id,
            token: @token,
          )
          out.print "#{result.class}:"
          out.pretty result
        end

        private

        def authorization
          CandyCheck::PlayStore.authorization(options["json_key_file"])
        end
      end
    end
  end
end
