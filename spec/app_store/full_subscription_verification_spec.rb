require 'spec_helper'

describe CandyCheck::AppStore::FullSubscriptionVerification do
  subject do
    CandyCheck::AppStore::FullSubscriptionVerification.new(endpoint, data, secret)
  end
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

  it 'returns a verification failure when status is 0 and receipt is missing' do
    response = {
      'status' => 0,
      'latest_receipt_info' => [
        { 'item_id' => 'some_id' },
        { 'item_id' => 'some_other_id' }
      ]
    }
    with_mocked_response(response) do
      result = subject.call!
      result.must_be_instance_of CandyCheck::AppStore::VerificationFailure
      result.code.must_equal(0)
    end
  end

  it 'returns a verification failure when status is 0 and latest_receipt_info is missing' do
    response = {
      'status' => 0,
      'receipt' => { 'item_id' => 'some_id' },
    }
    with_mocked_response(response) do
      result = subject.call!
      result.must_be_instance_of CandyCheck::AppStore::VerificationFailure
      result.code.must_equal(0)
    end
  end

  it 'returns a struct containing a Receipt and a ReceiptCollection when status is 0 and receipt and latest_receipt_info is present' do
    response = {
      'status' => 0,
      'receipt' => {'item_id' => 'some_id'},
      'latest_receipt_info' => [
        { 'item_id' => 'some_id' },
        { 'item_id' => 'some_other_id' }
      ]
    }
    with_mocked_response(response) do
      result = subject.call!
      result.receipt_collection.must_be_instance_of CandyCheck::AppStore::ReceiptCollection
      result.receipt_collection.receipts.must_be_instance_of Array
      last = result.receipt_collection.receipts.last
      last.must_be_instance_of CandyCheck::AppStore::Receipt
      last.item_id.must_equal('some_other_id')
      result.receipt.must_be_instance_of CandyCheck::AppStore::Receipt

    end
  end

  private

  DummyClient = Struct.new(:response) do
    attr_reader :receipt_data, :secret

    def verify(receipt_data, secret)
      @receipt_data = receipt_data
      @secret = secret
      response
    end
  end

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
