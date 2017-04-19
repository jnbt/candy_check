require 'multi_json'

module CandyCheck
  module PlayStore
    class AuthorizationBuilder
      # API endpoint
      API_URL = 'https://accounts.google.com/o/oauth2/token'.freeze
      # API scope for Android services
      API_SCOPE = Google::Apis::AndroidpublisherV2::AUTH_ANDROIDPUBLISHER

      def initialize(config)
        @config = config
      end

      def build_authorization
        if config.use_client_secrets?
          build_from_client_secrets
        else
          build_from_api_key
        end
      end

      private

      attr_reader :config

      def build_from_client_secrets
        file = File.new(config.secrets_file)
        Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: file,
          scope: API_SCOPE
        )
      ensure
        file.close if file
      end

      def build_from_api_key
        Signet::OAuth2::Client.new(
          token_credential_uri: API_URL,
          audience:             API_URL,
          scope:                API_SCOPE,
          issuer:               config.issuer,
          signing_key:          load_api_key
        )
      end

      def load_api_key
        key_file   = config.key_file
        key_secret = config.key_secret || 'notasecret'
        Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
      end
    end
  end
end
