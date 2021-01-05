require 'spec_helper'

describe CandyCheck::CLI::Commands::AppStore do
  include WithCommand
  subject { CandyCheck::CLI::Commands::AppStore }
  let(:arguments) { [receipt, options] }
  let(:receipt) { 'data' }
  let(:options) do
    {
      environment: :sandbox
    }
  end

  before do
    stub = proc do |*args|
      @verifier = DummyAppStoreVerifier.new(*args)
    end
    CandyCheck::AppStore::Verifier.stub :new, stub do
      run_command!
    end
  end

  describe 'default' do
    it 'uses the receipt and the options' do
      _(@verifier.config.environment).must_equal :sandbox
      _(@verifier.arguments).must_equal [receipt, nil]
      _(out.lines).must_equal ['Hash:', { result: :stubbed }]
    end
  end

  describe 'with secret' do
    let(:options) do
      {
        environment: :production,
        secret: 'notasecret'
      }
    end

    it 'uses the secret for verification' do
      _(@verifier.config.environment).must_equal :production
      _(@verifier.arguments).must_equal [receipt, 'notasecret']
      _(out.lines).must_equal ['Hash:', { result: :stubbed }]
    end
  end

  private

  DummyAppStoreVerifier = Struct.new(:config) do
    attr_reader :arguments

    def verify(*arguments)
      @arguments = arguments
      { result: :stubbed }
    end
  end
end
