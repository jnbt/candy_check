module CandyCheck
  module CLI
    module Commands
      # Command to verify an AppStore receipt token
      class AppStore < Base
        # Prepare a verification run from the terminal
        # @param receipt [String]
        # @param options [Hash]
        # @option options [String] :secret A shared secret to use
        # @option options [String] :environment The environment to use
        # @option options [String] :mode The verifiation mode to use
        def initialize(receipt, options)
          @receipt = receipt
          super(options)
        end

        # Print the result of the verification to the terminal
        def run
          verifier = CandyCheck::AppStore::Verifier.new(config)
          result = call_verifier(verifier)
          out.print "#{result.class}:"
          out.pretty result
        end

        private

        def call_verifier(verifier)
          case options[:mode]
          when "verify"
            verifier.verify(@receipt, options[:secret])
          when "verify_subscription"
            verifier.verify_subscription(@receipt, options[:secret])
          else
            raise "Unknown verification mode: #{options[:mode]}"
          end
        end

        def config
          CandyCheck::AppStore::Config.new(
            environment: options[:environment].to_sym,
          )
        end
      end
    end
  end
end
