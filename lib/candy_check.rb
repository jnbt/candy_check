require 'candy_check/version'
require 'candy_check/config'

# Module to check and verify in-app receipts
module CandyCheck
  # Reads the config for this module
  # @return [Config]
  def self.config
    @config ||= Config.new
  end

  # Configure this module
  def self.configure
    yield config
  end
end
