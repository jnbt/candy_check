module CandyCheck
  module PlayStore
    # Error thrown when the module isn't booted before the first
    # verification check
    class BootRequiredError < RuntimeError; end

    # Boot the module
    def self.boot!
      @client = build_client
      @client.boot!
    end

    # Contacts the Google API and requests the product state
    # @param package [String] to query
    # @param product_id [String] to query
    # @param token [String] to use for authentication
    # @return [Receipt] or [VerificationFailure]
    def self.verify(package, product_id, token)
      check_boot!
      verification = Verifier.new(@client, package, product_id, token)
      verification.call!
    end

    private

    def self.check_boot!
      return if @client
      fail BootRequiredError, 'You need to boot the PlayStore service first: '\
                              'CandyCheck::PlayStore.boot!'
    end

    def self.config
      CandyCheck.config.play_store
    end

    def self.build_client
      Client.new(ClientConfig.new(config.__hash__))
    end
  end
end
