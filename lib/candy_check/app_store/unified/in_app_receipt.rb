module CandyCheck
  module AppStore
    module Unified
      # Describes a receipt for an in-app purchase.
      # It's part of ios 7 style unified receip format
      class InAppReceipt
        include Utils::AttributeReader
        # @return [Hash] the raw attributes returned from the server
        attr_reader :attributes

        # Initializes a new instance which bases on a JSON result
        # from Apple's verification server
        # @param attributes [Hash]
        def initialize(attributes)
          @attributes = attributes
        end

        # The number of items purchased
        # @return [Integer]
        def quantity
          read_integer('quantity')
        end

        # The product identifier of the item that was purchased
        # @return [String]
        def product_id
          read('product_id')
        end

        # The transaction identifier of the item that was purchased
        # @return [String]
        def transaction_id
          read('transaction_id')
        end

        # For a transaction that restores a previous transaction,
        # the transaction identifier of the original transaction.
        # Otherwise, identical to the transaction identifier
        # @return [String]
        def original_transaction_id
          read('original_transaction_id')
        end

        # The date and time that the item was purchased
        # @return [DateTime]
        def purchase_date
          read_datetime_from_string('purchase_date')
        end

        # For a transaction that restores a previous transaction,
        # the date of the original transaction
        # @return [DateTime]
        def original_purchase_date
          read_datetime_from_string('original_purchase_date')
        end

        # For a transaction that was canceled by Apple customer support,
        # the time and date of the cancellation
        # @return [DateTime]
        def cancellation_date
          read_datetime_from_string('cancellation_date')
        end

        # The expiration date for the subscription,
        # expressed as the number of milliseconds
        # since January 1, 1970, 00:00:00 GMT.
        # @return [DateTime]
        def expires_date
          read_datetime_from_string('expires_date')
        end

        EXPIRATION_INTENTS = {
          1 => 'Customer canceled their subscription.',
          2 => 'Billing error; for example customer’s payment information'\
               'was no longer valid.',
          3 => 'Customer did not agree to a recent price increase.',
          4 => 'Product was not available for purchase at the time of renewal.',
          5 => 'Unknown error.'
        }.freeze

        # For an expired subscription, the reason for the
        # subscription expiration.
        # @return [Integer]
        def expiration_intent
          read_integer('expiration_intent')
        end

        # For an expired subscription, the reason for the
        # subscription expiration.
        # @return [String]
        def expiration_intent_string
          code = expiration_intent
          code && EXPIRATION_INTENTS[code]
        end

        CANCELATION_REASONS = {
          1 => 'Customer canceled their transaction due to an actual' \
               'or perceived issue within your app.',
          0 => 'Transaction was canceled for another reason, for example, if' \
                'the customer made the purchase accidentally.'
        }.freeze

        # For a transaction that was cancelled, the reason for cancellation
        # @return [Integer]
        def cancellation_reason
          read_integer('cancellation_reason')
        end

        # For a transaction that was cancelled, the reason for cancellation
        # @return [String]
        def cancellation_reason_string
          code = cancellation_reason
          code && CANCELATION_REASONS[code]
        end

        # For a subscription, whether or not it is in the Free Trial period.
        # rubocop:disable PredicateName
        def is_trial_period
          # rubocop:enable PredicateName
          read_bool('is_trial_period')
        end

        # A string that the App Store uses to uniquely identify the
        # application that created the transaction
        # return [String]
        def app_item_id
          read('app_item_id')
        end

        # An arbitrary number that uniquely identifies a revision
        # of your application
        # return [String]
        def version_external_identifier
          read('version_external_identifier')
        end
      end
    end
  end
end
