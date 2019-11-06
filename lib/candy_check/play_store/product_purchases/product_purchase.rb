module CandyCheck
  module PlayStore
    module ProductPurchases
      # Describes a successful response from the PlayStore verification server
      class ProductPurchase
        include Utils::AttributeReader

        # Returns the raw ProductPurchase from google-api-client gem
        # @return [Google::Apis::AndroidpublisherV3::ProductPurchase]
        attr_reader :product_purchase

        # Purchased product (0 is purchased, don't ask me why)
        # @see https://developers.google.com/android-publisher/api-ref/purchases/products
        PURCHASE_STATE_PURCHASED = 0

        # A consumed product
        CONSUMPTION_STATE_CONSUMED = 1

        # Initializes a new instance which bases on a JSON result
        # from PlayStore API servers
        # @param product_purchase [Google::Apis::AndroidpublisherV3::ProductPurchase]
        def initialize(product_purchase)
          @product_purchase = product_purchase
        end

        # The purchase state of the order. Possible values are:
        #   * 0: Purchased
        #   * 1: Cancelled
        # @return [Fixnum]
        def purchase_state
          @product_purchase.purchase_state
        end

        # The consumption state of the inapp product. Possible values are:
        #   * 0: Yet to be consumed
        #   * 1: Consumed
        # @return [Fixnum]
        def consumption_state
          @product_purchase.consumption_state
        end

        # The developer payload which was used when buying the product
        # @return [String]
        def developer_payload
          @product_purchase.developer_payload
        end

        # This kind represents an inappPurchase object in the androidpublisher
        # service.
        # @return [String]
        def kind
          @product_purchase.kind
        end

        # The order id
        # @return [String]
        def order_id
          @product_purchase.order_id
        end

        # The time the product was purchased, in milliseconds since the
        # epoch (Jan 1, 1970)
        # @return [Fixnum]
        def purchase_time_millis
          @product_purchase.purchase_time_millis
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

        # The date and time the product was purchased
        # @return [DateTime]
        def purchased_at
          Time.at(purchase_time_millis / 1000).utc.to_datetime
        end
      end
    end
  end
end
