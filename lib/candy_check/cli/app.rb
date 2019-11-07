require "thor"

module CandyCheck
  module CLI
    # Main class for the executable 'candy_check'
    # @example
    #   $> candy_check help
    class App < Thor
      package_name "CandyCheck"

      desc "app_store RECEIPT_DATA", "Verify a base64 encoded AppStore receipt"
      method_option :environment,
                    default: "production",
                    type: :string,
                    enum: %w(production sandbox),
                    aliases: "-e",
                    desc: "The environment to use for verfication"
      method_option :secret,
                    aliases: "-s",
                    type: :string,
                    desc: "The shared secret for auto-renewable subscriptions"

      def app_store(receipt)
        Commands::AppStore.run(receipt, options)
      end

      desc "play_store PACKAGE PRODUCT_ID TOKEN", "Verify PlayStore purchase"
      method_option :json_key_file,
                    required: true,
                    type: :string,
                    aliases: "-k",
                    desc: "The json key file to use for API authentication"

      def play_store(package, product_id, token)
        Commands::PlayStore.run(package, product_id, token, options)
      end

      desc "version", 'Print the gem\'s version'

      def version
        Commands::Version.run
      end
    end
  end
end
