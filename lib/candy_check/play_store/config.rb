module CandyCheck
  module PlayStore
    # Configure the usage of the official Google API SDK client
    class Config < Utils::Config
      # @return [String] your application name
      attr_reader :application_name
      # @return [String] your application's version
      attr_reader :application_version
      # @return [String] your issuer's service account e-mail
      attr_reader :issuer
      # @deprecated Use secrets_file instead
      # @return [String] the path to your local *.p12 certificate file
      attr_reader :key_file
      # @deprecated Use secrets_file instead
      # @return [String] the secret to load your certificate file
      attr_reader :key_secret
      # @deprecated No discovery cache is used anymore
      # @return [String] an optional file to cache the discovery API result
      attr_reader :cache_file
      # @return [String] the path to your local *.json secrets file
      attr_reader :secrets_file

      # Initializes a new configuration from a hash
      # @param attributes [Hash]
      # @example Initialize with a discovery cache file
      #   ClientConfig.new(
      #     application_name: 'YourApplication',
      #     application_version: '1.0',
      #     issuer: 'abcdefg@developer.gserviceaccount.com',
      #     secrets_file: 'local/client_secrets.json'
      #   )
      def initialize(attributes)
        super
      end

      # @return [Boolean] True if a secret_file is given
      def use_client_secrets?
        !secrets_file.nil?
      end

      private

      KEY_DEPRECATION = 'will be removed in' \
        ' the next version. Use secrets_file instead. For more information' \
        ' see: https://github.com/jnbt/candy_check#playstore-1'.freeze

      def validate!
        validates_presence(:application_name)
        validates_presence(:application_version)
        validates_presence(:issuer)

        deprecate(:cache_file, 'is obsolete.')
        deprecate(:key_file, KEY_DEPRECATION)
        deprecate(:key_secret, KEY_DEPRECATION)
      end
    end
  end
end
