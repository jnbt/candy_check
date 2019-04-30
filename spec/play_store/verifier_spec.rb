require "spec_helper"

describe CandyCheck::PlayStore::Verifier do
  subject { CandyCheck::PlayStore::Verifier.new }
  let(:package) { "the_package" }
  let(:product_id) { "the_product" }
  let(:token) { "the_token" }

  it "uses a verifier when booted" do
    result = :stubbed
    with_mocked_verifier(result) do
      subject.verify(package, product_id, token).must_be_same_as result

      assert_recorded(
        [package, product_id, token]
      )
    end
  end

  it "uses a subscription verifier when booted" do
    result = :stubbed
    with_mocked_verifier(result) do
      subject.verify_subscription(
        package, product_id, token
      ).must_be_same_as result

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
    CandyCheck::PlayStore::ProductPurchases::ProductVerification.stub :new, stub do
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
end
