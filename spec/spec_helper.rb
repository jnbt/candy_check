# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require 'candy_check'
require 'candy_check/cli'

require 'minitest/autorun'
require 'minitest/around/spec'

require 'webmock/minitest'

require 'timecop'

require_relative 'support/with_fixtures'
require_relative 'support/with_temp_file'
require_relative 'support/with_command'

ENV['DEBUG'] && Google::APIClient.logger.level = Logger::DEBUG

module MiniTest
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
