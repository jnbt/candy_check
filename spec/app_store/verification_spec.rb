# frozen_string_literal: true

require 'spec_helper'

describe CandyCheck::AppStore::Verification do
  subject { CandyCheck::AppStore::Verification.new(endpoint, data, secret) }
  let(:endpoint) { 'https://some.endpoint' }
  let(:data)     { 'some_data'   }
  let(:secret)   { 'some_secret' }

  it 'returns a verification failure for status != 0' do
    with_mocked_response('status' => 21_000) do |client, recorded|
      result = subject.call!
      client.receipt_data.must_equal data
      client.secret.must_equal secret

      recorded.first.must_equal [endpoint]

      result.must_be_instance_of CandyCheck::AppStore::VerificationFailure
      result.code.must_equal 21_000
    end
  end

  it 'returns a verification failure when receipt is missing' do
    with_mocked_response({}) do |client, recorded|
      result = subject.call!
      client.receipt_data.must_equal data
      client.secret.must_equal secret

      recorded.first.must_equal [endpoint]

      result.must_be_instance_of CandyCheck::AppStore::VerificationFailure
      result.code.must_equal(-1)
    end
  end

  describe 'when status is 0' do
    describe 'when receipt present in ios 6 trasaction format' do
      it 'returns a receipt' do
        response = { 'status' => 0, 'receipt' => { 'item_id' => 'some_id' } }
        with_mocked_response(response) do
          result = subject.call!
          result.must_be_instance_of CandyCheck::AppStore::Receipt
          result.item_id.must_equal('some_id')
        end
      end
    end

    describe 'when receipt present in ios 7 unified format' do
      it 'returns a unified app receipt' do
        response = {
          'status' => 0,
          'receipt' => { 'bundle_id' => 'some_bundle_id' }
        }
        with_mocked_response(response) do
          result = subject.call!
          result.must_be_instance_of CandyCheck::AppStore::Unified::AppReceipt
          result.bundle_id.must_equal('some_bundle_id')
        end
      end
    end
  end

  private

  def with_mocked_response(response)
    recorded = []
    dummy    = DummyClient.new(response)
    stub     = proc do |*args|
      recorded << args
      dummy
    end
    CandyCheck::AppStore::Client.stub :new, stub do
      yield dummy, recorded
    end
  end
end
