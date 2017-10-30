module CandyCheck
  module AppStore
    # Describes a successful response from the AppStore verification server
    class SubscriptionReceipt
      attr_reader :receipt, :receipt_collection

      # Initializes a new instance
      def initialize(receipt, receipt_collection)
        @receipt = receipt
        @receipt_collection = receipt_collection
      end

      def transactions
        @receipt_collection.receipts
      end

      def valid?
        @receipt.is_a?(CandyCheck::AppStore::Receipt) &&
          @receipt_collection.is_a?(CandyCheck::AppStore::ReceiptCollection)
      end
    end
  end
end
