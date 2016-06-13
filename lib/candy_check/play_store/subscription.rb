module CandyCheck
  module PlayStore
    # Describes a succeful subscription validation
    class Subscription
      include Utils::AttributeReader

      # @return [Hash] the raw attributes returned from the server
      attr_reader :attributes

      # Values of paymentState
      PAYMENT_PENDING = 0
      PAYMENT_RECEIVED = 1

      # Values of cancelReason
      PAYMENT_CANCELED = 0
      PAYMENT_FAILED = 1

      # Initializes a new instance which bases on a JSON result
      # from Google's servers
      # @param attributes [Hash]
      def initialize(attributes)
        @attributes = attributes
      end

      # Check if the expiration date is passed
      # @return [bool]
      def expired?
        overdue_days > 0
      end

      # Check if in trial. This is actually not given by Google, but we assume
      # that it is a trial going on if the paid amount is 0 and
      # renewal is activated.
      # @return [bool]
      def trial?
        price_is_zero = price_amount_micros == 0
        price_is_zero && payment_received?
      end

      # see if payment is ok
      # @return [bool]
      def payment_received?
        payment_state == PAYMENT_RECEIVED
      end

      # see if payment is pending
      # @return [bool]
      def payment_pending?
        payment_state == PAYMENT_PENDING
      end

      # see if payment has failed according to Google
      # @return [bool]
      def payment_failed?
        cancel_reason == PAYMENT_FAILED
      end

      # see if this the user has canceled its subscription
      # @return [bool]
      def canceled_by_user?
        cancel_reason == PAYMENT_CANCELED
      end

      # Get number of overdue days. If this is negative, it is not overdue.
      # @return [Integer]
      def overdue_days
        (Date.today - expires_at.to_date).to_i
      end

      def auto_renewing?
        read_bool('autoRenewing')
      end

      def payment_state
        read_integer('paymentState')
      end

      def price_amount_micros
        read_integer('priceAmountMicros')
      end

      def cancel_reason
        read_integer('cancelReason')
      end

      def kind
        read('kind')
      end

      def developer_payload
        read('developerPayload')
      end

      def price_currency_code
        read('priceCurrencyCode')
      end

      def start_time_millis
        read_integer('startTimeMillis')
      end

      def expiry_time_millis
        read_integer('expiryTimeMillis')
      end

      # Get start time
      # @return [DateTime]
      def starts_at
        read_datetime_from_millis('startTimeMillis')
      end

      # Get expiration date
      # @return [DateTime]
      def expires_at
        read_datetime_from_millis('expiryTimeMillis')
      end
    end
  end
end
