module CandyCheck
  module PlayStore
    # Describes a successfully validated subscription
    class Subscription
      include Utils::AttributeReader

      # @return [Hash] the raw attributes returned from the server
      attr_reader :attributes

      # The payment of the subscription is pending (paymentState)
      PAYMENT_PENDING = 0
      # The payment of the subscript is received (paymentState)
      PAYMENT_RECEIVED = 1
      # The subscription was canceled by the user (cancelReason)
      PAYMENT_CANCELED = 0
      # The payment failed during processing (cancelReason)
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
        (Time.now.utc.to_date - expires_at.to_date).to_i
      end

      # Get the auto renewal status as given by Google
      # @return [bool] true if renewing automatically, false otherwise
      def auto_renewing?
        read_bool('autoRenewing')
      end

      # Get the payment state as given by Google
      # @return [Integer]
      def payment_state
        read_integer('paymentState')
      end

      # Get the price amount for the subscription in micros in the payed
      # currency
      # @return [Integer]
      def price_amount_micros
        read_integer('priceAmountMicros')
      end

      # Get the cancel reason, as given by Google
      # @return [Integer]
      def cancel_reason
        read_integer('cancelReason')
      end

      # Get the kind of subscription as stored in the android publisher service
      # @return [String]
      def kind
        read('kind')
      end

      # Get developer-specified supplemental information about the order
      # @return [String]
      def developer_payload
        read('developerPayload')
      end

      # Get the currency code in ISO 4217 format, e.g. "GBP" for British pounds
      # @return [String]
      def price_currency_code
        read('priceCurrencyCode')
      end

      # Get start time for subscription in milliseconds since Epoch
      # @return [Integer]
      def start_time_millis
        read_integer('startTimeMillis')
      end

      # Get expiry time for subscription in milliseconds since Epoch
      # @return [Integer]
      def expiry_time_millis
        read_integer('expiryTimeMillis')
      end

      # Get start time in UTC
      # @return [DateTime]
      def starts_at
        read_datetime_from_millis('startTimeMillis')
      end

      # Get expiration time in UTC
      # @return [DateTime]
      def expires_at
        read_datetime_from_millis('expiryTimeMillis')
      end
    end
  end
end
