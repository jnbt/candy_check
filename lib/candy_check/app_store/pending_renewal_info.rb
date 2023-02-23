module CandyCheck
  module AppStore
    
    # Encapsulates Apple's pending renewal info included with renewable subscriptions.
    class PendingRenewalInfo
      include Utils::AttributeReader
      
      # @return [Hash] the raw attributes returned from the server
      attr_reader :attributes

      # Initializes a new instance with a hash mapping to the attributes.
      # @param [Hash] the attributes for the pending renewal info
      def initialize(attributes)
        @attributes = attributes
      end

      # productIdentifier property of the product that the customer’s subscription renews.
      # @return [String]
      def auto_renew_product_id
        read('auto_renew_product_id')
      end

      # The renewal status for the auto-renewable subscription.
      # @return [Integer]
      def auto_renew_status
        read_integer('auto_renew_status')
      end

      # The reason a subscription expired.
      # @return [Integer]
      def expiration_intent
        read_integer('expiration_intent')
      end

      # The grace period expiration time.
      # @return [DateTime]
      def grace_period_expires_date
        read_datetime_from_string('grace_period_expires_date')
      end

      # The grace period expiration time in UNIX epoch time format, in milliseconds.
      # @return [String]
      def grace_period_expires_date_ms
        read_integer('grace_period_expires_date_ms')
      end

      # The grace period expiration time in PST.
      # @return [DateTime]
      def grace_period_expires_date_pst
        read_datetime_from_string('grace_period_expires_date_pst')
      end

      # Whether an auto-renewable subscription is in the billing retry period.
      # @return [Integer]
      def is_in_billing_retry_period
        read_integer('is_in_billing_retry_period')
      end

      # The offer-reference name of the subscription offer code that the customer redeemed.
      # @return [String]
      def offer_code_ref_name
        read('offer_code_ref_name')
      end

      # The transaction identifier of the original purchase.
      # @return [String]
      def original_transaction_id
        read('original_transaction_id')
      end

      # The price consent status for a subscription price increase.
      # @return [Integer]
      def price_consent_status
        read_integer('price_consent_status')
      end

      # The unique identifier of the product purchased.
      # @return [String]
      def product_id
        read('product_id')
      end

      # The identifier of the promotional offer for an auto-renewable subscription that the user redeemed.
      # @return [String]
      def promotional_offer_id
        read('promotional_offer_id')
      end
    end
  end
end