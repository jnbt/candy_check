require 'spec_helper'
require 'candy_check/test_helper'

describe CandyCheck::TestHelper::CallRecorder do
  subject { CandyCheck::TestHelper::CallRecorder.new(:one, :two) }
  let(:error_class) { CandyCheck::TestHelper::CallRecorder::ExpectationError }

  it 'has a size and allows each' do
    subject.size.must_equal 0
    subject.each do
      fail 'this should not happen'
    end

    subject << [:a, :b]
    subject.size.must_equal 1
    subject.each do |rec|
      rec.one.must_equal :a
      rec.two.must_equal :b
    end
  end

  it 'asserts recorded calls must be have expected amount' do
    subject.assert_calls # should not fail

    subject << [:a, :b]
    expect_raise 'Expected 0 call(s), but recorded 1 call(s)' do
      subject.assert_calls
    end

    subject.assert_calls([:a, :b]) # should not fail

    expect_raise 'Expected 2 call(s), but recorded 1 call(s)' do
      subject.assert_calls([:a, :b], [:a, :b])
    end
  end

  it 'asserts each recorded call' do
    subject << [:a, :b]
    subject.assert_calls([:a, :b]) # should not fail

    subject << [:b, :e]
    expect_raise 'Expected call #<struct one=:a, two=:b>, but recorded ' \
                 'call #<struct one=:b, two=:e>' do
      subject.assert_calls([:a, :b], [:a, :b])
    end

    subject.assert_calls([:a, :b], [:b, :e]) # should not fail
  end

  private

  def expect_raise(message, &block)
    error = block.must_raise error_class
    error.message.must_equal message
  end
end
