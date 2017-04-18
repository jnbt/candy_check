module CandyCheck
  module PlayStore
    # Describes a successful response from the Google verification server
    class Receipt
      include Utils::AttributeReader

      # @return [Hash] the raw attributes returned from the server
      attr_reader :attributes

      # Purchased product (0 is purchased, don't ask me why)
      # @see https://developers.google.com/android-publisher/api-ref/purchases/products
      PURCHASE_STATE_PURCHASED = 0

      # A consumed product
      CONSUMPTION_STATE_CONSUMED = 1

      # Initializes a new instance which bases on a JSON result
      # from Google API servers
      # @param attributes [Hash]
      def initialize(attributes)
        @attributes = attributes
      end

      # A product may be purchased or canceled. Ensure a receipt
      # is valid before granting some candy
      # @return [Boolean]
      def valid?
        purchase_state == PURCHASE_STATE_PURCHASED
      end

      # A purchased product may already be consumed. In this case you
      # should grant candy even if it's valid.
      # @return [Boolean]
      def consumed?
        consumption_state == CONSUMPTION_STATE_CONSUMED
      end

      # The purchase state of the order. Possible values are:
      #   * 0: Purchased
      #   * 1: Cancelled
      # @return [Fixnum]
      def purchase_state
        read_integer(:purchase_state)
      end

      # The consumption state of the inapp product. Possible values are:
      #   * 0: Yet to be consumed
      #   * 1: Consumed
      # @return [Fixnum]
      def consumption_state
        read_integer(:consumption_state)
      end

      # The developer payload which was used when buying the product
      # @return [String]
      def developer_payload
        read(:developer_payload)
      end

      # This kind represents an inappPurchase object in the androidpublisher
      # service.
      # @return [String]
      def kind
        read(:kind)
      end

      # The time the product was purchased, in milliseconds since the
      # epoch (Jan 1, 1970)
      # @return [Fixnum]
      def purchase_time_millis
        read_integer(:purchase_time_millis)
      end

      # The date and time the product was purchased
      # @return [DateTime]
      def purchased_at
        read_datetime_from_millis(:purchase_time_millis)
      end
    end
  end
end
