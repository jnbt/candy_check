require 'spec_helper'

describe "#{CandyCheck::AppStore} core" do
  subject { CandyCheck::AppStore }
  let(:endpoint) { 'http://some.endpoint' }

  around do |spec|
    with_config(CandyCheck.config) do |config|
      config.app_store do |app_store|
        app_store.verification_url = endpoint
      end
      spec.call
    end
  end

  it 'verifies by using the verifier without secret' do
    with_mocked_verifier do |recorded|
      got = subject.verify('some_data')
      got.must_equal :stubbed
      recorded.first.must_equal [endpoint, 'some_data', nil]
    end
  end

  it 'verifies by using the verifier with secret' do
    with_mocked_verifier do |recorded|
      got = subject.verify('some_data', 'some_secret')
      got.must_equal :stubbed
      recorded.first.must_equal [endpoint, 'some_data', 'some_secret']
    end
  end

  private

  def with_mocked_verifier
    recorded = []
    stub     = proc do |*args|
      recorded << args
      DummyAppStoreVerification.new(*args)
    end
    CandyCheck::AppStore::Verification.stub :new, stub do
      yield recorded
    end
  end

  class DummyAppStoreVerification < Struct.new(:endpoint, :data, :secret)
    def call!
      :stubbed
    end
  end
end
