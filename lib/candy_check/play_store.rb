require "google-apis-androidpublisher_v3"
require "googleauth"

require "candy_check/play_store/android_publisher_service"
require "candy_check/play_store/product_purchases/product_purchase"
require "candy_check/play_store/subscription_purchases/subscription_purchase"
require "candy_check/play_store/product_purchases/product_verification"
require "candy_check/play_store/product_acknowledgements/acknowledgement"
require "candy_check/play_store/product_acknowledgements/response"
require "candy_check/play_store/subscription_purchases/subscription_verification"
require "candy_check/play_store/subscription_acknowledgements/acknowledgement"
require "candy_check/play_store/subscription_acknowledgements/response"
require "candy_check/play_store/verification_failure"
require "candy_check/play_store/verifier"
require "candy_check/play_store/acknowledger"

module CandyCheck
  # Module to request and verify a AppStore receipt
  module PlayStore
    # Build an authorization object
    # @param json_key_file [String]
    # @return [Google::Auth::ServiceAccountCredentials]
    def self.authorization(json_key_file)
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(json_key_file),
        scope: "https://www.googleapis.com/auth/androidpublisher",
      )
    end
  end
end
