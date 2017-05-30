# frozen_string_literal: true
module CandyCheck
  module PlayStore
    # Configure the usage of the official Google API SDK client
    class Config < Utils::Config
      # @return [String] your application name
      attr_reader :application_name
      # @return [String] your application's version
      attr_reader :application_version
      # @return [String] an optional file to cache the discovery API result
      attr_reader :cache_file
      # @return [String] your issuer's service account e-mail
      attr_reader :issuer
      # @return [String] the path to your local *.p12 certificate file
      attr_reader :key_file
      # @return [String] the secret to load your certificate file
      attr_reader :key_secret

      # Initializes a new configuration from a hash
      # @param attributes [Hash]
      # @example Initialize with a discovery cache file
      #   ClientConfig.new(
      #     application_name: 'YourApplication',
      #     application_version: '1.0',
      #     cache_file: 'tmp/google_api_cache',
      #     issuer: 'abcdefg@developer.gserviceaccount.com',
      #     key_file: 'local/google.p12',
      #     key_secret: 'notasecret'
      #   )
      def initialize(attributes)
        super
      end

      # @return [String] the decrypted API key from Google
      def api_key
        @api_key ||= begin
          Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
        end
      end

      private

      def validate!
        validates_presence(:application_name)
        validates_presence(:application_version)
        validates_presence(:issuer)
        validates_presence(:key_file)
        validates_presence(:key_secret)
      end
    end
  end
end
