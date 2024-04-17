require "candy_check"
require "candy_check/cli"

def in_continuous_integration_environment?
  ENV["CI"] || ENV["TRAVIS"] || ENV["CONTINUOUS_INTEGRATION"]
end

require "simplecov"

SimpleCov.start do
  if in_continuous_integration_environment?
    require "simplecov-lcov"

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = "coverage/lcov.info"
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end
end

require "minitest/autorun"
require "minitest/around/spec"
require "minitest/focus" unless in_continuous_integration_environment?

require "webmock/minitest"
require "vcr"

require "timecop"

require "pry"

require_relative "support/with_fixtures"
require_relative "support/with_temp_file"
require_relative "support/with_command"

ENV["DEBUG"] && Google::APIClient.logger.level = Logger::DEBUG

module Minitest
  module Assertions
    # The first parameter must be ```true```, not coercible to true.
    def assert_true(obj, msg = nil)
      msg = message(msg) { "<true> expected but was #{mu_pp obj}" }
      assert obj == true, msg
    end

    # The first parameter must be ```false```, not just coercible to false.
    def assert_false(obj, msg = nil)
      msg = message(msg) { "<false> expected but was #{mu_pp obj}" }
      assert obj == false, msg
    end
  end

  module Expectations
    infect_an_assertion :assert_true, :must_be_true, :unary
    infect_an_assertion :assert_false, :must_be_false, :unary
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end
