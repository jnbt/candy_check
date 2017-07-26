require 'spec_helper'

describe CandyCheck::AppStore::VerificationFailure do
  subject { CandyCheck::AppStore::VerificationFailure }
  describe '.fetch' do
    let(:known) do
      [21_000, 21_002, 21_003, 21_004, 21_005, 21_006, 21_007, 21_008, 21_010]
    end

    it 'fetched an failure with message for every known code' do
      known.each do |code|
        got = subject.fetch(code)
        got.code.must_equal code
        got.message.wont_equal 'Unknown error'
      end
    end

    it 'fetched an failure for unknown codes' do
      got = subject.fetch(1234)
      got.code.must_equal 1234
      got.message.must_equal 'Unknown error'
    end

    it 'fetched an failure for nil code' do
      got = subject.fetch(nil)
      got.code.must_equal(-1)
      got.message.must_equal 'Unknown error'
    end

    describe 'when internal data access error occured' do
      let(:known) { 21_100..21_199 }
      it 'fetched an failure with internal data access error message' do
        known.each do |code|
          failure = subject.fetch(code)
          failure.code.must_equal code
          failure.message.must_equal 'Internal data access error'
        end
      end
    end
  end
end
