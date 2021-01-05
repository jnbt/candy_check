require 'spec_helper'

describe CandyCheck::AppStore::VerificationFailure do
  subject { CandyCheck::AppStore::VerificationFailure }
  let(:known) do
    [21_000, 21_002, 21_003, 21_004, 21_005, 21_006, 21_007, 21_008]
  end

  it 'fetched an failure with message for every known code' do
    known.each do |code|
      got = subject.fetch(code)
      _(got.code).must_equal code
      _(got.message).wont_equal 'Unknown error'
    end
  end

  it 'fetched an failure for unknown codes' do
    got = subject.fetch(1234)
    _(got.code).must_equal 1234
    _(got.message).must_equal 'Unknown error'
  end

  it 'fetched an failure for nil code' do
    got = subject.fetch(nil)
    _(got.code).must_equal(-1)
    _(got.message).must_equal 'Unknown error'
  end
end
