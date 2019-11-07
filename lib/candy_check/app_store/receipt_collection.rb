module CandyCheck
  module AppStore
    # Store multiple {Receipt}s in order to perform collective operation on them
    class ReceiptCollection
      # Multiple receipts as in verfication response
      # @return [Array<Receipt>]
      attr_reader :receipts

      # Initializes a new instance which bases on a JSON result
      # from Apple's verification server
      # @param attributes [Array<Hash>] raw data from Apple's server
      def initialize(attributes)
        @receipts = attributes.map {|r| Receipt.new(r) }.sort{ |a, b|
          a.purchase_date - b.purchase_date
        }
      end

      # Check if the latest expiration date is passed
      # @return [bool]
      def expired?
        expires_at.to_time <= Time.now.utc
      end

      # Check if in trial
      # @return [bool]
      def trial?
        @receipts.last.is_trial_period
      end

      # Get latest expiration date
      # @return [DateTime]
      def expires_at
        @receipts.last.expires_date
      end

      # Get number of overdue days. If this is negative, it is not overdue.
      # @return [Integer]
      def overdue_days
        (Date.today - expires_at.to_date).to_i
      end
    end
  end
end
