module CandyCheck
  module PlayStore
    # A file-based repository to cache a local copy of the Google API
    # discovery as suggested by Google.
    # @see https://github.com/google/google-api-ruby-client
    class DiscoveryRepository
      # Create a new instance bound to a single file path
      # @param file_path [String] to save and load the cached copy
      def initialize(file_path)
        @file_path = file_path
      end

      # Tries to load a cached copy of the discovery API. Me be nil if
      # no cached version is available
      # @return [Google::APIClient::API]
      def load
        return unless @file_path && File.exist?(@file_path)
        File.open(@file_path, 'rb') do |file|
          return Marshal.load(file)
        end
      end

      # Tries to save a local copy of the discovery API.
      # @param discovery [Google::APIClient::API]
      def save(discovery)
        return unless @file_path && discovery
        File.open(@file_path, 'wb') do |file|
          Marshal.dump(discovery, file)
        end
      end
    end
  end
end
