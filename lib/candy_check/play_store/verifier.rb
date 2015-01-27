module CandyCheck
  module PlayStore
    # Verifies purchase tokens against the Google API.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Verifier
      # Error thrown when the verifier isn't booted before the first
      # verification check or on double invocation
      class BootRequiredError < RuntimeError; end

      # @return [Config] the current configuration
      attr_reader :config

      # Initializes a new verifier for the application which is bound
      # to a configuration
      # @param config [Config]
      def initialize(config)
        @config = config
      end

      # Boot the module
      def boot!
        boot_error('You\'re only allowed to boot the verifier once') if @client
        @client = Client.new(config)
        @client.boot!
      end

      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param product_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt, VerificationFailure] the result
      def verify(package, product_id, token)
        check_boot!
        verification = Verification.new(@client, package, product_id, token)
        verification.call!
      end

      private

      def check_boot!
        return if @client
        boot_error 'You need to boot the verifier service first: '\
                   'CandyCheck::PlayStore::Verifier#boot!'
      end

      def boot_error(message)
        fail BootRequiredError, message
      end
    end
  end
end
