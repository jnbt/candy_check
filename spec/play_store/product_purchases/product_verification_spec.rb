require "spec_helper"

describe CandyCheck::PlayStore::ProductPurchases::ProductVerification do
  subject do
    CandyCheck::PlayStore::ProductPurchases::ProductVerification.new(package, product_id, token)
  end
  let(:package) { "the_package" }
  let(:product_id) { "the_product" }
  let(:token) { "the_token" }

  describe "valid" do
    let(:response) do
      {
        "kind" => "androidpublisher#productPurchase",
        "purchaseTimeMillis" => "1421676237413",
        "purchaseState" => 0,
        "consumptionState" => 0,
        "developerPayload" => "payload that gets stored and returned",
      }
    end

    it "returns a product purchase" do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::ProductPurchases::ProductPurchase
      result.valid?.must_be_true
      result.consumed?.must_be_false
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
end
