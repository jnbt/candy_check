require 'spec_helper'

describe CandyCheck::AppStore::SubscriptionVerification do
  subject do
    CandyCheck::AppStore::SubscriptionVerification.new(endpoint, data, secret)
  end
  let(:endpoint) { 'https://some.endpoint' }
  let(:data)     { 'some_data'   }
  let(:secret)   { 'some_secret' }

  include AppStore::WithMockedResponse

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

  it 'returns a collection of receipt when status is 0 and receipts exists' do
    response = {
      'status' => 0,
      'latest_receipt_info' => [
        { 'item_id' => 'some_id' },
        { 'item_id' => 'some_other_id' }
      ]
    }
    with_mocked_response(response) do
      result = subject.call!
      result.must_be_instance_of CandyCheck::AppStore::ReceiptCollection
      result.receipts.must_be_instance_of Array
      last = result.receipts.last
      last.must_be_instance_of CandyCheck::AppStore::Receipt
      last.item_id.must_equal('some_other_id')
    end
  end
end
