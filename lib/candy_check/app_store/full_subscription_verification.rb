# frozen_string_literal: true

module CandyCheck
  module AppStore
    # Verifies a receipt and latest_receipt_info block
    # The call return either a {SubscriptionReceipt} or a {VerificationFailure}
    class FullSubscriptionVerification < CandyCheck::AppStore::Verification
      # Performs the verification against the remote server
      # @return [SubscriptionReceipt] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        return VerificationFailure.fetch(@response['status']) unless valid?
        subscription_receipt
      end

      private

      def subscription_receipt
        receipt = Receipt.new(@response['receipt'])
        receipt_collection = ReceiptCollection.new(
          @response['latest_receipt_info']
        )

        SubscriptionReceipt.new(receipt, receipt_collection)
      end

      def valid?
        super && @response['latest_receipt_info']
      end
    end
  end
end
