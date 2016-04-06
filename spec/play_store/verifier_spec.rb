require 'spec_helper'

describe CandyCheck::PlayStore::Verifier do
  subject { CandyCheck::PlayStore::Verifier.new(config) }
  let(:config) do
    CandyCheck::PlayStore::Config
      .new(
        application_name: 'YourApplication',
        application_version: '1.0',
        issuer: 'abcdefg@developer.gserviceaccount.com',
        key_file: 'local/google.p12',
        key_secret: 'notasecret'
      )
  end
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }

  it 'holds the config' do
    subject.config.must_be_same_as config
  end

  it 'requires a boot before verification' do
    proc do
      subject.verify(package, product_id, token)
    end.must_raise CandyCheck::PlayStore::Verifier::BootRequiredError
  end

  it 'it configures and boots a client but raises on second boot!' do
    with_mocked_client do
      subject.boot!
      @client.config.must_be_same_as config
      @client.booted.must_be_true
    end

    proc do
      subject.boot!
    end.must_raise CandyCheck::PlayStore::Verifier::BootRequiredError
  end

  it 'uses a verifier when booted' do
    result = :stubbed
    with_mocked_client do
      subject.boot!
    end
    with_mocked_verifier(result) do
      subject.verify(package, product_id, token).must_be_same_as result

      assert_recorded(
        [@client, package, product_id, token]
      )
    end
  end

  private

  def with_mocked_verifier(*results)
    @recorded ||= []
    stub = proc do |*args|
      @recorded << args
      DummyPlayStoreVerification.new(*args).tap { |v| v.results = results }
    end
    CandyCheck::PlayStore::Verification.stub :new, stub do
      yield
    end
  end

  def with_mocked_client
    stub = proc do |*args|
      @client = DummyPlayStoreClient.new(*args)
    end
    CandyCheck::PlayStore::Client.stub :new, stub do
      yield
    end
  end

  def assert_recorded(*calls)
    @recorded.must_equal calls
  end

  DummyPlayStoreVerification = Struct.new(:client, :package,
                                          :product_id, :token) do
    attr_accessor :results
    def call!
      results.shift
    end
  end

  DummyPlayStoreClient = Struct.new(:config) do
    attr_reader :booted
    def boot!
      @booted = true
    end
  end
end
