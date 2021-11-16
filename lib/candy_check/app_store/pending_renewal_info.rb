module CandyCheck
  module AppStore
    # Encapsulates Apple's pending renewal info included with renewable subscriptions.
    class PendingRenewalInfo
      attr_reader :auto_renew_status
      attr_reader :auto_renew_product_id
      attr_reader :expiration_intent
      attr_reader :is_in_billing_retry_period
      attr_reader :original_transaction_id
      attr_reader :product_id

      # Initializes a new instance with a hash mapping to the attributes.
      # @param [Hash] the attributes for the pending renewal info
      def initialize(attributes)
        @auto_renew_status          = attributes['auto_renew_status']
        @auto_renew_product_id      = attributes['auto_renew_product_id']
        @expiration_intent          = attributes['expiration_intent']
        @is_in_billing_retry_period = attributes['is_in_billing_retry_period']
        @original_transaction_id    = attributes['original_transaction_id']
        @product_id                 = attributes['product_id']
      end
    end
  end
end