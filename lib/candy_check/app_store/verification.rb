# frozen_string_literal: true
module CandyCheck
  module AppStore
    # Verifies a receipt block against a verification server.
    # The call return either an {Receipt} or a {VerificationFailure}
    class Verification
      # @return [String] the verification URL to use
      attr_reader :endpoint_url
      # @return [String] the raw data to be verified
      attr_reader :receipt_data
      # @return [String] the optional shared secret
      attr_reader :secret

      # Constant for successful responses
      STATUS_OK = 0

      # Builds a fresh verification run
      # @param endpoint_url [String] the verification URL to use
      # @param receipt_data [String] the raw data to be verified
      # @param secret [String] the optional shared secret
      def initialize(endpoint_url, receipt_data, secret = nil)
        @endpoint_url = endpoint_url
        @receipt_data = receipt_data
        @secret = secret
      end

      # Performs the verification against the remote server
      # @return [Receipt] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        if valid?
          Receipt.new(@response['receipt'])
        else
          VerificationFailure.fetch(@response['status'])
        end
      end

      private

      def response_status_ok?
        @response['status'] == STATUS_OK
      end

      def valid?
        @response && response_status_ok? && @response['receipt']
      end

      def verify!
        client    = Client.new(endpoint_url)
        @response = client.verify(receipt_data, secret)
      end
    end
  end
end
