module CandyCheck
  module AppStore
    # Store multiple {Receipt}s in order to perform collective operation on them
    class ReceiptCollection
      # @return [Array<Receipt>]
      attr_reader :receipts

      # Initializes a new instance which bases on a JSON result
      # from Apple's verification server
      # @param attributes [Hash]
      def initialize(attributes)
        @receipts = attributes.map { |r| Receipt.new(r) }
      end
    end
  end
end
