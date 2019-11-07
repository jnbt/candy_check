module CandyCheck
  module AppStore
    # Verifies a latest_receipt_info block against a verification server.
    # The call return either an {ReceiptCollection} or a {VerificationFailure}
    class SubscriptionVerification < CandyCheck::AppStore::Verification
      # Builds a fresh verification run
      # @param endpoint_url [String] the verification URL to use
      # @param receipt_data [String] the raw data to be verified
      # @param secret [String] optional: shared secret
      # @param product_ids [Array<String>] optional: select specific products
      def initialize(
        endpoint_url,
        receipt_data,
        secret = nil,
        product_ids = nil
      )
        super(endpoint_url, receipt_data, secret)
        @product_ids = product_ids
      end

      # Performs the verification against the remote server
      # @return [ReceiptCollection] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        if valid?
          build_collection(@response['latest_receipt_info'])
        else
          VerificationFailure.fetch(@response['status'])
        end
      end

      private

      def build_collection(latest_receipt_info)
        unless @product_ids.nil?
          latest_receipt_info = latest_receipt_info.select do |info|
            @product_ids.include?(info['product_id'])
          end
        end
        ReceiptCollection.new(latest_receipt_info)
      end

      def valid?
        status_is_ok = @response['status'] == STATUS_OK
        @response && status_is_ok && @response['latest_receipt_info']
      end
    end
  end
end
