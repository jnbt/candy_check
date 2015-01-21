require 'spec_helper'

describe CandyCheck::CLI::Commands::PlayStore do
  include WithCommand
  subject { CandyCheck::CLI::Commands::PlayStore }
  let(:arguments) { [package, product_id, token, options] }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }
  let(:options) do
    {
      application_name: 'YourApplication',
      application_version: '1.0',
      issuer: 'abcdefg@developer.gserviceaccount.com',
      key_file: 'local/google.p12',
      key_secret: 'notasecret'
    }
  end

  before do
    stub = proc do |*args|
      @verifier = DummyPlayStoreVerifier.new(*args)
    end
    CandyCheck::PlayStore::Verifier.stub :new, stub do
      run_command!
    end
  end

  it 'calls and outputs the verifier' do
    options.each do |k, v|
      @verifier.config.public_send(k).must_equal v
    end
    @verifier.arguments.must_equal [package, product_id, token]
    out.must_be 'Hash:', result: :stubbed
  end

  private

  class DummyPlayStoreVerifier < Struct.new(:config)
    attr_reader :arguments, :booted

    def boot!
      @booted = true
    end

    def verify(*arguments)
      @arguments = arguments
      { result: :stubbed }
    end
  end
end
