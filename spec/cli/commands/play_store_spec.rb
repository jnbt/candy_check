require "spec_helper"

describe CandyCheck::CLI::Commands::PlayStore do
  include WithCommand
  subject { CandyCheck::CLI::Commands::PlayStore }
  let(:arguments) { [package, product_id, token, options] }
  let(:package) { "the_package" }
  let(:product_id) { "the_product" }
  let(:token) { "the_token" }
  let(:options) do
    { json_key_file: "/home/chris/Desktop/candy_check/key.json" }
  end

  before do
    stub = proc do |*args|
      @verifier = DummyPlayStoreVerifier.new(*args)
    end
    CandyCheck::PlayStore::Verifier.stub :new, stub do
      run_command!
    end
  end

  it "calls and outputs the verifier" do
    options.each do |k, v|
      @verifier.config.public_send(k).must_equal v
    end
    @verifier.arguments.must_equal [package, product_id, token]
    out.must_be "Hash:", result: :stubbed
  end

  private

  DummyPlayStoreVerifier = Struct.new(:config) do
    attr_reader :arguments, :booted

    def verify(*arguments)
      @arguments = arguments
      { result: :stubbed }
    end
  end
end
