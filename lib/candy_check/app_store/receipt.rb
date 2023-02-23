module CandyCheck
  module AppStore
    # Describes a successful response from the AppStore verification server
    class Receipt
      include Utils::AttributeReader

      # @return [Hash] the raw attributes returned from the server
      attr_reader :attributes

      # Initializes a new instance which bases on a JSON result
      # from Apple's verification server
      # @param attributes [Hash]
      def initialize(attributes)
        @attributes = attributes
      end

      # In most cases a receipt is a valid transaction except when the
      # transaction was canceled.
      # @return [Boolean]
      def valid?
        !has?('cancellation_date')
      end

      # The receipt's transaction id
      # @return [String]
      def transaction_id
        read('transaction_id')
      end

      # The receipt's original transaction id which might differ from
      # the transaction id for restored products
      # @return [String]
      def original_transaction_id
        read('original_transaction_id')
      end

      # The version number for the app
      # @return [String]
      def app_version
        read('bvrs')
      end

      # The app's bundle identifier
      # @return [String]
      def bundle_identifier
        read('bid')
      end

      # The app's identifier of the product (SKU)
      # @return [String]
      def product_id
        read('product_id')
      end

      # The app's item id of the product
      # @return [String]
      def item_id
        read('item_id')
      end

      # The quantity of the product
      # @return [Integer]
      def quantity
        read_integer('quantity')
      end

      # The purchase date
      # @return [DateTime]
      def purchase_date
        read_datetime_from_string('purchase_date')
      end

      # The original purchase date which might differ from the
      # actual purchase date for restored products
      # @return [DateTime]
      def original_purchase_date
        read_datetime_from_string('original_purchase_date')
      end

      # The date of when Apple has canceled this transaction.
      # From Apple's documentation: "Treat a canceled receipt
      # the same as if no purchase had ever been made."
      # @return [DateTime]
      def cancellation_date
        read_datetime_from_string('cancellation_date')
      end

      # The date of a subscription's expiration
      # @return [DateTime]
      def expires_date
        read_datetime_from_string('expires_date')
      end

      # rubocop:disable PredicateName
      def is_trial_period
        # rubocop:enable PredicateName
        read_bool('is_trial_period')
      end
    end
  end
end
