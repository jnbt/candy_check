require 'spec_helper'

describe CandyCheck::AppStore::Unified::Verification do
  subject do
    CandyCheck::AppStore::Unified::Verification.new(endpoint, data, secret)
  end

  let(:endpoint) { 'https://some.endpoint' }
  let(:data)     { 'some_data'   }
  let(:secret)   { 'some_secret' }

  include AppStore::WithMockedResponse

  describe 'when validation failed' do
    describe 'when status != 0' do
      it 'returns a verification failure' do
        with_mocked_response('status' => 21_000, 'receipt' => {}) do
          result = subject.call!
          result.must_be_instance_of CandyCheck::AppStore::VerificationFailure
          result.code.must_equal 21_000
        end
      end
    end
  end

  describe 'when validation passed successfully' do
    it 'returns instance of Unified::VerifiedResponse' do
      with_mocked_response('status' => 0, 'receipt' => {}) do
        result = subject.call!
        result.must_be_instance_of(
          CandyCheck::AppStore::Unified::VerifiedResponse
        )
      end
    end
  end
end
