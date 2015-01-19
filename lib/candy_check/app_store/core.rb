module CandyCheck
  module AppStore
    # Contacts the configured endpoint and requests the receipt's data
    # @param receipt_data [String] base64 encoded data string from the app
    # @param secret [String] the password for auto-renewable subscriptions
    # @return [Receipt] or [VerificationFailure]
    def self.verify(receipt_data, secret = nil)
      verification = Verifier.new(config.verification_url, receipt_data, secret)
      verification.call!
    end

    private

    def self.config
      CandyCheck.config.app_store
    end
  end
end
