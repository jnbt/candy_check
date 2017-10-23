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

        CANCELATION_REASONS = {
          1 => 'Customer canceled their transaction due to an actual' \
               'or perceived issue within your app.',
          0 => 'Transaction was canceled for another reason, for example, if' \
                'the customer made the purchase accidentally.'
        }.freeze

        # For a transaction that was cancelled, the reason for cancellation
        # @return [String]
        def cancellation_reason
          code = read_integer('cancellation_reason')
          code && CANCELATION_REASONS[code]
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
