require "spec_helper"

describe CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionVerification do
  subject do
    CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionVerification.new(
      package, product_id, token
    )
  end
  let(:package) { "the_package" }
  let(:product_id) { "the_product" }
  let(:token) { "the_token" }

  describe "valid" do
    let(:response) do
      {
        "kind" => "androidpublisher#subscriptionPurchase",
        "startTimeMillis" => "1459540113244",
        "expiryTimeMillis" => "1462132088610",
        "autoRenewing" => false,
        "developerPayload" => "payload that gets stored and returned",
        "cancelReason" => 0,
        "paymentState" => "1",
      }
    end

    it "returns a subscription" do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase
      result.expired?.must_be_true
    end
  end

  describe "failure" do
    let(:response) do
      {
        "error" => {
          "code" => 401,
          "message" => "The current user has insufficient permissions",
        },
      }
    end

    it "returns a verification failure" do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.code.must_equal 401
    end
  end

  describe "empty" do
    let(:response) do
      {}
    end

    it "returns a verification failure" do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.code.must_equal(-1)
    end
  end

  describe "invalid response kind" do
    let(:response) do
      {
        "kind" => "something weird",
      }
    end

    it "returns a verification failure" do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
    end
  end
end
