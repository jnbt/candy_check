require 'spec_helper'

describe CandyCheck::AppStore::Verifier do
  subject { CandyCheck::AppStore::Verifier.new(config) }
  let(:config) do
    CandyCheck::AppStore::Config.new(environment: environment)
  end
  let(:environment) { :production }
  let(:data)     { 'some_data'   }
  let(:secret)   { 'some_secret' }
  let(:receipt)  { CandyCheck::AppStore::Receipt.new({}) }
  let(:receipt_collection) { CandyCheck::AppStore::ReceiptCollection.new({}) }
  let(:production_endpoint) do
    'https://buy.itunes.apple.com/verifyReceipt'
  end
  let(:sandbox_endpoint) do
    'https://sandbox.itunes.apple.com/verifyReceipt'
  end

  it 'holds the config' do
    subject.config.must_be_same_as config
  end

  describe 'sandbox' do
    let(:environment) { :sandbox }

    it 'uses sandbox endpoint without retry on success' do
      with_mocked_verifier(receipt) do
        subject.verify(data, secret).must_be_same_as receipt
        assert_recorded([sandbox_endpoint, data, secret])
      end
    end

    it 'only uses sandbox endpoint for normal failures' do
      failure = get_failure(21_000)
      with_mocked_verifier(failure) do
        subject.verify(data, secret).must_be_same_as failure
        assert_recorded([sandbox_endpoint, data, secret])
      end
    end

    it 'retries production endpoint for redirect error' do
      failure = get_failure(21_008)
      with_mocked_verifier(failure, receipt) do
        subject.verify(data, secret).must_be_same_as receipt
        assert_recorded(
          [sandbox_endpoint, data, secret],
          [production_endpoint, data, secret]
        )
      end
    end
  end

  describe 'production' do
    let(:environment) { :production }

    it 'uses production endpoint without retry on success' do
      with_mocked_verifier(receipt) do
        subject.verify(data, secret).must_be_same_as receipt
        assert_recorded([production_endpoint, data, secret])
      end
    end

    it 'only uses production endpoint for normal failures' do
      failure = get_failure(21_000)
      with_mocked_verifier(failure) do
        subject.verify(data, secret).must_be_same_as failure
        assert_recorded([production_endpoint, data, secret])
      end
    end

    it 'retries production endpoint for redirect error' do
      failure = get_failure(21_007)
      with_mocked_verifier(failure, receipt) do
        subject.verify(data, secret).must_be_same_as receipt
        assert_recorded(
          [production_endpoint, data, secret],
          [sandbox_endpoint, data, secret]
        )
      end
    end
  end

  describe 'subscription' do
    let(:environment) { :production }

    it 'uses production endpoint without retry on success' do
      with_mocked_verifier(receipt_collection) do
        subject.verify_subscription(
          data, secret
        ).must_be_same_as receipt_collection
        assert_recorded([production_endpoint, data, secret, nil])
      end
    end

    it 'only uses production endpoint for normal failures' do
      failure = get_failure(21_000)
      with_mocked_verifier(failure) do
        subject.verify_subscription(data, secret).must_be_same_as failure
        assert_recorded([production_endpoint, data, secret, nil])
      end
    end

    it 'retries production endpoint for redirect error' do
      failure = get_failure(21_007)
      with_mocked_verifier(failure, receipt) do
        subject.verify_subscription(data, secret).must_be_same_as receipt
        assert_recorded(
          [production_endpoint, data, secret, nil],
          [sandbox_endpoint, data, secret, nil]
        )
      end
    end

    it 'passed the product_ids' do
      product_ids = ['product_1']
      with_mocked_verifier(receipt_collection) do
        subject.verify_subscription(
          data, secret, product_ids
        ).must_be_same_as receipt_collection
        assert_recorded([production_endpoint, data, secret, product_ids])
      end
    end
  end

  private

  def with_mocked_verifier(*results)
    @recorded ||= []
    stub = proc do |*args|
      @recorded << args
      DummyAppStoreVerification.new(*args).tap { |v| v.results = results }
    end
    CandyCheck::AppStore::Verification.stub :new, stub do
      yield
    end
  end

  def assert_recorded(*calls)
    @recorded.must_equal calls
  end

  def get_failure(code)
    CandyCheck::AppStore::VerificationFailure.fetch(code)
  end

  class DummyAppStoreVerification
    attr_reader :endpoint, :data, :secret, :product_ids
    attr_accessor :results

    def initialize(endpoint, data, secret, product_ids = nil)
      @endpoint = endpoint
      @data = data
      @secret = secret
      @product_ids = product_ids
    end

    def call!
      results.shift
    end
  end
end
