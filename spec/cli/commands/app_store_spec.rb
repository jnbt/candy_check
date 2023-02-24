require "spec_helper"

describe CandyCheck::CLI::Commands::AppStore do
  include WithCommand
  subject { CandyCheck::CLI::Commands::AppStore }
  let(:arguments) { [receipt, options] }
  let(:receipt) { "data" }
  let(:options) do
    {
      mode: "verify",
      environment: :sandbox,
    }
  end
  let(:dummy_verifier_class) do
    Struct.new(:config) do
      attr_reader :arguments, :mode

      def verify(*arguments)
        @mode = :verify
        @arguments = arguments
        { result: :stubbed }
      end

      def verify_subscription(*arguments)
        @mode = :verify_subscription
        @arguments = arguments
        { result: :stubbed }
      end
    end
  end

  before do
    stub = proc do |*args|
      @verifier = dummy_verifier_class.new(*args)
    end
    CandyCheck::AppStore::Verifier.stub :new, stub do
      run_command!
    end
  end

  describe "default" do
    it "uses the receipt and the options" do
      _(@verifier.mode).must_equal :verify
      _(@verifier.config.environment).must_equal :sandbox
      _(@verifier.arguments).must_equal [receipt, nil]
      _(out.lines).must_equal ["Hash:", { result: :stubbed }]
    end
  end

  describe "with secret" do
    let(:options) do
      {
        mode: "verify",
        environment: :production,
        secret: "notasecret",
      }
    end

    it "uses the secret for verification" do
      _(@verifier.mode).must_equal :verify
      _(@verifier.config.environment).must_equal :production
      _(@verifier.arguments).must_equal [receipt, "notasecret"]
      _(out.lines).must_equal ["Hash:", { result: :stubbed }]
    end
  end

  describe "mode: verify_subscription" do
    let(:options) do
      {
        mode: "verify_subscription",
        environment: :sandbox,
      }
    end

    it "uses verify_subscription" do
      _(@verifier.mode).must_equal :verify_subscription
    end
  end
end
