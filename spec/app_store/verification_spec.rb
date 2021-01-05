require 'spec_helper'

describe CandyCheck::AppStore::Verification do
  subject { CandyCheck::AppStore::Verification.new(endpoint, data, secret) }
  let(:endpoint) { 'https://some.endpoint' }
  let(:data)     { 'some_data'   }
  let(:secret)   { 'some_secret' }

  it 'returns a verification failure for status != 0' do
    with_mocked_response('status' => 21_000) do |client, recorded|
      result = subject.call!
      _(client.receipt_data).must_equal data
      _(client.secret).must_equal secret

      _(recorded.first).must_equal [endpoint]

      _(result).must_be_instance_of CandyCheck::AppStore::VerificationFailure
      _(result.code).must_equal 21_000
    end
  end

  it 'returns a verification failure when receipt is missing' do
    with_mocked_response({}) do |client, recorded|
      result = subject.call!
      _(client.receipt_data).must_equal data
      _(client.secret).must_equal secret

      _(recorded.first).must_equal [endpoint]

      _(result).must_be_instance_of CandyCheck::AppStore::VerificationFailure
      _(result.code).must_equal(-1)
    end
  end

  it 'returns a receipt when status is 0 and receipt exists' do
    response = { 'status' => 0, 'receipt' => { 'item_id' => 'some_id' } }
    with_mocked_response(response) do
      result = subject.call!
      _(result).must_be_instance_of CandyCheck::AppStore::Receipt
      _(result.item_id).must_equal('some_id')
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
