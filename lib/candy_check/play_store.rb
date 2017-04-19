require 'googleauth'
require 'google/apis/androidpublisher_v2'
require 'google/api_client/auth/key_utils'

require 'candy_check/play_store/authorization_builder'
require 'candy_check/play_store/client'
require 'candy_check/play_store/config'
require 'candy_check/play_store/receipt'
require 'candy_check/play_store/subscription'
require 'candy_check/play_store/verification'
require 'candy_check/play_store/subscription_verification'
require 'candy_check/play_store/verification_failure'
require 'candy_check/play_store/verifier'

module CandyCheck
  # Module to request and verify a AppStore receipt
  module PlayStore
  end
end
