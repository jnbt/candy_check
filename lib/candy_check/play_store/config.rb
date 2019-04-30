module CandyCheck
  module PlayStore
    # Configure the usage of the official Google API SDK client
    class Config < Utils::Config
      attr_reader :json_key_file

      # Initializes a new configuration from a hash
      # @param attributes [Hash]
      # @example Initialize with a discovery cache file
      #   ClientConfig.new(
      #     application_name: 'YourApplication',
      #     application_version: '1.0',
      #     issuer: 'abcdefg@developer.gserviceaccount.com',
      #     json_key_file: 'local/key.json',
      #   )
      def initialize(attributes)
        super
        authorize!
      end

      private

      def validate!
        validates_presence(:json_key_file)
      end

      def authorize!
        scope = "https://www.googleapis.com/auth/androidpublisher"

        authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(json_key_file),
          scope: scope,
        )

        Google::Apis::RequestOptions.default.authorization = authorizer
      end
    end
  end
end
