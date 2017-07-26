module CandyCheck
  module AppStore
    module Unified
      # Wraps response from apple verification server
      class VerifiedResponse
        # @return [Unified::AppReceipt]
        attr_reader :receipt

        # @return [<Unified::InAppReceipt>] the collection containing all
        #   in-app purchase transactions. This excludes transactions for
        #   a consumable product that have been marked as finished by your app.
        #   Present only for auto-renewable subscription.
        attr_reader :latest_receipt_info

        # @return [<Unified::InAppReceipt>] the collection where each
        #   element contains the pending renewal information for each
        #   auto-renewable subscription.
        #   Present only for auto-renewable subscription.
        attr_reader :pending_renewal_info

        # @return [Unified::InAppReceipt, nil] the latest transaction from
        #   latest_receipt_info collection.
        #   Present only for auto-renewable subscription.
        attr_reader :latest_transaction

        # @return [DateTime, nil] the expiration date for subscription.
        #   Present only for auto-renewable subscription.
        attr_reader :expires_at

        # @return [Unified::InAppReceipt, nil] the pending renewal transaction
        #   for subscription identified by
        #   {latest_transaction.original_transaction_id}.
        #   Present only for auto-renewable subscription.
        attr_reader :pending_renewal_transaction

        # @param response [Hash] parsed response from apple
        #   verification server
        def initialize(response)
          @receipt = AppReceipt.new(response['receipt'])
          @latest_receipt_info = fetch_latest_receipt_info(response)
          @pending_renewal_info = fetch_pending_renewal_info(response)
          @latest_transaction = latest_receipt_info.last
          @expires_at = latest_transaction && latest_transaction.expires_date
          @pending_renewal_transaction = fetch_pending_renewal_transaction
        end

        # Check if the {#expires_at} is passed.
        # It makes sense only for subscriptions.
        # @return [Boolean]
        def expired?
          !expires_at.nil? &&
            expires_at.to_time <= Time.now.utc
        end

        # For a subscription, whether or not it is in the free trial period
        # @return [Boolean]
        def trial?
          !latest_transaction.nil? &&
            latest_transaction.trial_period?
        end

        # Check if subscription was canceled by Apple customer support
        # It makes sense only for subscriptions.
        # @return [Boolean]
        def canceled?
          !latest_transaction.nil? &&
            !latest_transaction.cancellation_date.nil?
        end

        # Check if subscription will auto-renew.
        # It makes sense only for subscriptions.
        # @return [Boolean]
        def will_renew?
          !pending_renewal_transaction.nil? &&
            pending_renewal_transaction.auto_renew?
        end

        # For an expired subscription, whether or not Apple is still
        # attempting to automatically renew the subscription.
        # It makes sense only for subscriptions.
        # @return [Boolean]
        def in_billing_retry_period?
          !pending_renewal_transaction.nil? &&
            pending_renewal_transaction.in_billing_retry_period?
        end

        # Check if response includes subscription
        # @return [Boolean]
        def subscription?
          !latest_transaction.nil?
        end

        private

        def fetch_latest_receipt_info(response)
          return [] unless response['latest_receipt_info']
          response['latest_receipt_info'].map do |receipt|
            InAppReceipt.new(receipt)
          end
        end

        def fetch_pending_renewal_info(response)
          return [] unless response['pending_renewal_info']
          response['pending_renewal_info'].map do |receipt|
            InAppReceipt.new(receipt)
          end
        end

        def fetch_pending_renewal_transaction
          return unless latest_transaction
          pending_renewal_info.find do |transaction|
            transaction.original_transaction_id ==
              latest_transaction.original_transaction_id
          end
        end
      end
    end
  end
end
