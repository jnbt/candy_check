module CandyCheck
  module AppStore
    # Verifies a receipt and latest_receipt_info block against a verification server.
    # The call return either a struct {<FullSubscriptionInfo receipt="foo", receipt_collection="bar">} or a {VerificationFailure}
    class FullSubscriptionVerification < CandyCheck::AppStore::Verification
      # Performs the verification against the remote server
      # @return [FullSubscriptionInfo] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        return VerificationFailure.fetch(@response['status']) unless valid?
        full_subscription_info
      end

      private

      def full_subscription_info
        receipt = Receipt.new(@response['receipt'])
        receipt_collection = ReceiptCollection.new(@response['latest_receipt_info'])

        OpenStruct.new(receipt: receipt, receipt_collection: receipt_collection)
      end

      def valid?
        super && @response['latest_receipt_info']
      end
    end
  end
end
