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
        boot_error('You\'re only allowed to boot the verifier once') if booted?
        @client = Client.new(config)
        @client.boot!
      end

      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param product_id [String] to query
      # @param token [String] to use for authentication
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def verify(package, product_id, token)
        check_boot!
        verification = Verification.new(@client, package, product_id, token)
        verification.call!
      end

      # Contacts the Google API and requests the product state
      # @param package [String] to query
      # @param subscription_id [String] to query
      # @param token [String] to use for authentication
      # @return [Subscription] if successful
      # @return [VerificationFailure] otherwise
      def verify_subscription(package, subscription_id, token)
        check_boot!
        v = SubscriptionVerification.new(
          @client, package, subscription_id, token
        )
        v.call!
      end

      private

      def booted?
        instance_variable_defined?(:@client)
      end

      def check_boot!
        return if booted?
        boot_error 'You need to boot the verifier service first: '\
                   'CandyCheck::PlayStore::Verifier#boot!'
      end

      def boot_error(message)
        raise BootRequiredError, message
      end
    end
  end
end
