require 'spec_helper'

describe CandyCheck::PlayStore::SubscriptionVerification do
  subject do
    CandyCheck::PlayStore::SubscriptionVerification.new(
      client, package, product_id, token
    )
  end
  let(:client)     { DummyGoogleSubsClient.new(response) }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }

  describe 'valid' do
    let(:response) do
      {
        :kind => 'androidpublisher#subscriptionPurchase',
        :start_time_millis => '1459540113244',
        :expiry_time_millis => '1462132088610',
        :autoRenewing => false,
        :developerPayload => 'payload that gets stored and returned',
        :cancelReason => 0,
        :paymentState => '1'
      }
    end

    it 'calls the client with the correct paramters' do
      subject.call!
      client.package.must_equal package
      client.product_id.must_equal product_id
      client.token.must_equal token
    end

    it 'returns a subscription' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::Subscription
      result.expired?.must_be_true
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

  describe 'invalid response kind' do
    let(:response) do
      {
        :kind => 'something weird'
      }
    end

    it 'returns a verification failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
    end
  end

  private

  DummyGoogleSubsClient = Struct.new(:response) do
    attr_reader :package, :product_id, :token

    def boot!; end

    def verify_subscription(package, product_id, token)
      @package = package
      @product_id = product_id
      @token = token
      response
    end
  end
end
