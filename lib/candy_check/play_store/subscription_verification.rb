module CandyCheck
  module PlayStore
    # Verifies a purchase token against the Google API
    # The call return either an {Receipt} or an {VerificationFailure}
    class SubscriptionVerification < Verification
      # Performs the verification against the remote server
      # @return [Subscription] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        if valid?
          Subscription.new(@response)
        else
          VerificationFailure.new(@response['error'])
        end
      end

      private

      def valid?
        ok_kind = @response['kind'] == 'androidpublisher#subscriptionPurchase'
        @response && @response['expiryTimeMillis'] && ok_kind
      end

      def verify!
        @response = @client.verify_subscription(package, product_id, token)
      end
    end
  end
end
