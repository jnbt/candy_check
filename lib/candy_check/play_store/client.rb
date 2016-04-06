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
      # Error thrown if the discovery of the API wasn't successful
      class DiscoveryError < RuntimeError; end

      # API endpoint
      API_URL      = 'https://accounts.google.com/o/oauth2/token'.freeze
      # API scope for Android services
      API_SCOPE    = 'https://www.googleapis.com/auth/androidpublisher'.freeze
      # API discovery namespace
      API_DISCOVER = 'androidpublisher'.freeze
      # API version
      API_VERSION  = 'v2'.freeze

      # Initializes a client using a configuration.
      # @param config [ClientConfig]
      def initialize(config)
        self.config = config
      end

      # Boots a client by discovering the API's services and then authorizes
      # by fetching an access token.
      # If the config has a cache_file the client tries to load discovery
      def boot!
        self.api_client = Google::APIClient.new(
          application_name:    config.application_name,
          application_version: config.application_version
        )
        discover!
        authorize!
      end

      # Calls the remote API to load the product information for a specific
      # combination of parameter which should be loaded from the client.
      # @param package [String] the app's package name
      # @param product_id [String] the app's item id
      # @param token [String] the purchase token
      # @return [Hash] result of the API call
      def verify(package, product_id, token)
        api_client.execute(
          api_method: rpc.purchases.products.get,
          parameters: {
            'packageName' => package,
            'productId'   => product_id,
            'token'       => token
          }
        ).data.to_hash
      end

      private

      attr_accessor :config, :api_client, :rpc

      def discover!
        self.rpc = load_discover_dump || request_discover
        validate_rpc!
        write_discover_dump
      end

      def request_discover
        api_client.discovered_api(API_DISCOVER, API_VERSION)
      end

      def authorize!
        api_client.authorization = Signet::OAuth2::Client.new(
          token_credential_uri: API_URL,
          audience:             API_URL,
          scope:                API_SCOPE,
          issuer:               config.issuer,
          signing_key:          config.api_key
        )
        api_client.authorization.fetch_access_token!
      end

      def validate_rpc!
        return if rpc.purchases.products.get
        raise DiscoveryError, 'Unable to get the API discovery'
      rescue NoMethodError
        raise DiscoveryError, 'Unable to get the API discovery'
      end

      def load_discover_dump
        DiscoveryRepository.new(config.cache_file).load
      end

      def write_discover_dump
        DiscoveryRepository.new(config.cache_file).save(rpc)
      end
    end
  end
end
