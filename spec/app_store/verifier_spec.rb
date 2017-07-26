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
        assert_recorded([production_endpoint, data, secret])
      end
    end

    it 'only uses production endpoint for normal failures' do
      failure = get_failure(21_000)
      with_mocked_verifier(failure) do
        subject.verify_subscription(data, secret).must_be_same_as failure
        assert_recorded([production_endpoint, data, secret])
      end
    end

    it 'retries production endpoint for redirect error' do
      failure = get_failure(21_007)
      with_mocked_verifier(failure, receipt) do
        subject.verify_subscription(data, secret).must_be_same_as receipt
        assert_recorded(
          [production_endpoint, data, secret],
          [sandbox_endpoint, data, secret]
        )
      end
    end
  end

  describe 'unified' do
    let(:environment) { :production }
    let(:verified_response) do
      CandyCheck::AppStore::Unified::VerifiedResponse.new({})
    end

    subject do
      CandyCheck::AppStore::Verifier.new(config).verify_unified(data, secret)
    end

    it 'uses production endpoint without retry on success' do
      with_mocked_verifier(verified_response) do
        subject.must_be_same_as verified_response
        assert_recorded([production_endpoint, data, secret])
      end
    end

    it 'only uses production endpoint for normal failures' do
      failure = get_failure(21_000)
      with_mocked_verifier(failure) do
        subject.must_be_same_as failure
        assert_recorded([production_endpoint, data, secret])
      end
    end

    it 'retries production endpoint for redirect error' do
      failure = get_failure(21_007)
      with_mocked_verifier(failure, verified_response) do
        subject.must_be_same_as verified_response
        assert_recorded(
          [production_endpoint, data, secret],
          [sandbox_endpoint, data, secret]
        )
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

  DummyAppStoreVerification = Struct.new(:endpoint, :data, :secret) do
    attr_accessor :results
    def call!
      results.shift
    end
  end
end
