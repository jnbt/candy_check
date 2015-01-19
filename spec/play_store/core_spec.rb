require 'spec_helper'

describe "#{CandyCheck::PlayStore} core" do
  # module must be booted once!
  i_suck_and_my_tests_are_order_dependent!

  subject { CandyCheck::PlayStore }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }

  around do |spec|
    with_config(CandyCheck.config) do |config|
      config.play_store do |play_store|
        play_store.application_name    = 'Test app'
        play_store.application_version = '0.1'
        play_store.cache_file          = 'some/cache/path'
        play_store.issuer              = 'The issuer'
        play_store.key_file            = 'some/key/path'
        play_store.key_secret          = 'secret'
      end
      spec.call
    end
  end

  it 'requires a boot before verification' do
    proc do
      subject.verify(package, product_id, token)
    end.must_raise CandyCheck::PlayStore::BootRequiredError
  end

  it 'it configures and boots a client' do
    with_mocked_client do
      subject.boot!
      @client.config.application_name.must_equal 'Test app'
      @client.booted.must_be_true
    end
  end

  it 'uses a verifier when booted' do
    with_mocked_verifier do |recorded|
      got = subject.verify(package, product_id, token)
      got.must_equal :stubbed

      rec = recorded.first
      rec[0].must_be_instance_of DummyPlayStoreClient
      rec[1].must_equal package
      rec[2].must_equal product_id
      rec[3].must_equal token
    end
  end

  private

  def with_mocked_verifier
    recorded = []
    stub     = proc do |*args|
      recorded << args
      DummyPlayStoreVerifier.new(*args)
    end
    CandyCheck::PlayStore::Verifier.stub :new, stub do
      yield recorded
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

  class DummyPlayStoreVerifier < Struct.new(:client, :package,
                                            :product_id, :token)
    def call!
      :stubbed
    end
  end

  class DummyPlayStoreClient < Struct.new(:config)
    attr_reader :booted
    def boot!
      @booted = true
    end
  end
end
