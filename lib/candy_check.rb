require 'candy_check/version'
require 'candy_check/config'
require 'candy_check/app_store'
require 'candy_check/play_store'

# Module to check and verify in-app receipts
module CandyCheck
  # Reads the config for this module
  # @return [Config]
  def self.config
    @config ||= Config.new
  end

  # Configure this module
  # @yield [config] Allows changing the config
  # @yieldparam config [Config]
  # @return [Config]
  def self.configure
    yield config
    config
  end
end
