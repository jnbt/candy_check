module CandyCheck
  module PlayStore
    # Abstract knowledge about Discovery Repositories and when to read or write
    # to them.
    class DiscoveryApi
      # Error thrown if the discovery of the API wasn't successful
      class Error < RuntimeError; end

      # API discovery namespace
      API_DISCOVER = 'androidpublisher'.freeze
      # API version
      API_VERSION  = 'v2'.freeze

      # Create a new instance with the cache repository
      # @param attributes [Hash]
      def initialize(attributes)
        @repository = attributes.fetch(:repository)
      end

      def rpc(api_client:)
        rpc = load_discover_dump
        return rpc if rpc

        rpc = request_discover(api_client)
        validate_rpc!(rpc)
        write_discover_dump(rpc)

        rpc
      end

      private

      attr_reader :repository

      def request_discover(api_client)
        api_client.discovered_api(API_DISCOVER, API_VERSION)
      end

      def validate_rpc!(rpc)
        return if rpc.purchases.products.get
        raise Error, 'Unable to get the API discovery'
      rescue NoMethodError
        raise Error, 'Unable to get the API discovery'
      end

      def load_discover_dump
        repository.load
      end

      def write_discover_dump(rpc)
        repository.save(rpc)
      end
    end
  end
end
