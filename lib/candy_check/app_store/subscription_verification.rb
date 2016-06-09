module CandyCheck
  module AppStore
    # Verifies a latest_receipt_info block against a verification server.
    # The call return either an {ReceiptCollection} or a {VerificationFailure}
    class SubscriptionVerification < CandyCheck::AppStore::Verification
      # Performs the verification against the remote server
      # @return [ReceiptCollection] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        if valid?
          ReceiptCollection.new(@response['latest_receipt_info'])
        else
          VerificationFailure.fetch(@response['status'])
        end
      end
    end
  end
end
