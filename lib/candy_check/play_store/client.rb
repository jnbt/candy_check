require 'multi_json'

module CandyCheck
  module PlayStore
    # A client which uses the official Google API SDK to authenticate
    # and request product information from Google's API.
    #
    # @example Usage
    #   config = ClientConfig.new({...})
    #   client = Client.new(config)
    #   client.boot! # a single time
    #   client.verify('my.bundle', 'product_1', 'a-very-long-secure-token')
    #   # ... multiple calls from now on
    #   client.verify('my.bundle', 'product_1', 'another-long-token')
    class Client
      # Alias
      Androidpublisher = Google::Apis::AndroidpublisherV2

      # Error thrown if the discovery of the API wasn't successful
      # @deprecated No discovery is used anymore
      class DiscoveryError < RuntimeError; end

      # API endpoint
      API_URL      = 'https://accounts.google.com/o/oauth2/token'.freeze
      # API scope for Android services
      API_SCOPE    = 'https://www.googleapis.com/auth/androidpublisher'.freeze

      # Initializes a client using a configuration.
      # @param config [ClientConfig]
      def initialize(config)
        @config = config
      end

      # Boots a client by discovering the API's services and then authorizes
      # by fetching an access token.
      # If the config has a cache_file the client tries to load discovery
      def boot!
        @api_client = Androidpublisher::AndroidPublisherService.new
        authorize!
      end

      # Calls the remote API to load the product information for a specific
      # combination of parameter which should be loaded from the client.
      # @param package [String] the app's package name
      # @param product_id [String] the app's item id
      # @param token [String] the purchase token
      # @return [Hash] result of the API call
      def verify(package, product_id, token)
        execute(
          :get_purchase_product,
          package,
          product_id,
          token
        )
      end

      # Calls the remote API to load the product information for a specific
      # combination of parameter which should be loaded from the client.
      # @param package [String] the app's package name
      # @param subscription_id [String] the app's item id
      # @param token [String] the purchase token
      # @return [Hash] result of the API call
      def verify_subscription(package, subscription_id, token)
        execute(
          :get_purchase_subscription,
          package,
          subscription_id,
          token
        )
      end

      private

      attr_reader :config, :api_client

      # Execute api call through the API Client's HTTP command class
      # @param parameters [hash] the parameters to send to the command
      # @param api_method [Method] which api method to call
      # @return [hash] the data response, as a hash
      def execute(api_method, *parameters)
        api_client.public_send(api_method, *parameters).to_h
      rescue Google::Apis::ClientError => error
        parse_client_error(error)
      end

      def authorize!
        builder = AuthorizationBuilder.new(config)
        api_client.authorization = builder.build_authorization
        api_client.authorization.fetch_access_token!
      end

      # Needed to provide a compability layer between Google's API
      # client version < 0.8
      def parse_client_error(error)
        response = MultiJson.load(error.body)
        { error: response['error'] }
      rescue MultiJson::ParseError
        {
          error: {
            'code'    => error.status_code,
            'message' => error.body,
            'errors'  => []
          }
        }
      end
    end
  end
end
