require 'spec_helper'

describe CandyCheck::PlayStore::Verifier do
  subject do
    CandyCheck::PlayStore::Verifier.new(client, package, product_id, token)
  end
  let(:client)     { DummyGoogleClient.new(response) }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }

  describe 'valid' do
    let(:response) do
      {
        'kind' => 'androidpublisher#productPurchase',
        'purchaseTimeMillis' => '1421676237413',
        'purchaseState' => 0,
        'consumptionState' => 0,
        'developerPayload' => 'payload that gets stored and returned'
      }
    end

    it 'calls the client with the correct paramters' do
      subject.call!
      client.package.must_equal package
      client.product_id.must_equal product_id
      client.token.must_equal token
    end

    it 'returns a receipt' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::Receipt
      result.valid?.must_be_true
      result.consumed?.must_be_false
    end
  end

  describe 'failure' do
    let(:response) do
      {
        'error' => {
          'code'    => 401,
          'message' => 'The current user has insufficient permissions'
        }
      }
    end

    it 'returns a verification failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.code.must_equal 401
    end
  end

  describe 'empty' do
    let(:response) do
      {}
    end

    it 'returns a verification failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.code.must_equal(-1)
    end
  end

  private

  class DummyGoogleClient < Struct.new(:response)
    attr_reader :package, :product_id, :token

    def boot!
    end

    def verify(package, product_id, token)
      @package, @product_id, @token = package, product_id, token
      response
    end
  end
end
