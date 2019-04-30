module CandyCheck
  module CLI
    module Commands
      # Command to verify an PlayStore purchase
      class PlayStore < Base
        # Prepare a verification run from the terminal
        # @param package [String]
        # @param product_id [String]
        # @param token [String]
        # @param options [Hash]
        # @option options [String] :issuer to use for API access
        # @option options [String] :key_file to use for API access
        # @option options [String] :key_secret to decrypt the key file
        # @option options [String] :application_name for the API call
        # @option options [String] :application_version for the API call
        def initialize(package, product_id, token, options)
          @package = package
          @product_id = product_id
          @token = token
          super(options)
        end

        # Print the result of the verification to the terminal
        def run
          verifier = CandyCheck::PlayStore::Verifier.new(config)
          result = verifier.verify(@package, @product_id, @token)
          out.print "#{result.class}:"
          out.pretty result
        end

        private

        def config
          CandyCheck::PlayStore::Config.new(options)
        end
      end
    end
  end
end
