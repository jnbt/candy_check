require 'multi_json'
require 'net/http'

module CandyCheck
  module AppStore
    # Simple HTTP client to load the receipt's data from Apple's verification
    # servers (either sandbox or production).
    class Client
      # Mimetype for JSON objects
      JSON_MIME_TYPE = 'application/json'.freeze

      # Initialize a new client bound to an endpoint
      # @param endpoint_url [String]
      def initialize(endpoint_url)
        @uri = URI(endpoint_url)
      end

      # Contacts the configured endpoint and requests the receipt's data
      # @param receipt_data [String] base64 encoded data string from the app
      # @param secret [String] the password for auto-renewable subscriptions
      # @return [Hash]
      def verify(receipt_data, secret = nil)
        request  = build_request(build_request_parameters(receipt_data, secret))
        response = perform_request(request)
        MultiJson.load(response.body)
      end

      private

      def perform_request(request)
        build_http_connector.request(request)
      end

      def build_http_connector
        Net::HTTP.new(@uri.host, @uri.port).tap do |net|
          net.use_ssl = true
          net.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end
      end

      def build_request(parameters)
        Net::HTTP::Post.new(@uri.request_uri).tap do |post|
          post['Accept']       = JSON_MIME_TYPE
          post['Content-Type'] = JSON_MIME_TYPE
          post.body            = MultiJson.dump(parameters)
        end
      end

      def build_request_parameters(receipt_data, secret)
        {
          'receipt-data' => receipt_data
        }.tap do |h|
          h['password'] = secret if secret
        end
      end
    end
  end
end
