require "google/apis/androidpublisher_v3"

require "candy_check/play_store/client"
require "candy_check/play_store/config"
require "candy_check/play_store/product_purchases/product_purchase"
require "candy_check/play_store/subscription_purchases/subscription_purchase"
require "candy_check/play_store/product_purchases/product_verification"
require "candy_check/play_store/subscription_purchases/subscription_verification"
require "candy_check/play_store/verification_failure"
require "candy_check/play_store/verifier"

module CandyCheck
  # Module to request and verify a AppStore receipt
  module PlayStore
  end
end
