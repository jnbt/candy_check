require "spec_helper"

describe CandyCheck::PlayStore::ProductPurchases::ProductVerification do
  subject do
    CandyCheck::PlayStore::ProductPurchases::ProductVerification.new(
      package_name: package_name,
      product_id: product_id,
      token: token,
      authorization: authorization,
    )
  end
  let(:package_name) { "my_package_name" }
  let(:product_id) { "my_product_id" }
  let(:token) { "my_token" }
  let(:json_key_file) { File.expand_path("../../fixtures/play_store/random_dummy_key.json", __dir__) }

  let(:authorization) { CandyCheck::PlayStore.authorization(json_key_file) }

  describe "valid" do
    it "returns a product purchase" do
      VCR.use_cassette("play_store/product_purchases/valid_but_not_consumed") do
        result = subject.call!
        result.must_be_instance_of CandyCheck::PlayStore::ProductPurchases::ProductPurchase
        result.valid?.must_be_true
        result.consumed?.must_be_false
      end
    end
  end

  describe "failure" do
    it "returns a verification failure" do
      VCR.use_cassette("play_store/product_purchases/permission_denied") do
        result = subject.call!
        result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
        result.code.must_equal 401
      end
    end
  end

  describe "empty" do
    it "returns a verification failure" do
      VCR.use_cassette("play_store/product_purchases/response_with_empty_body") do
        result = subject.call!
        result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
        result.code.must_equal(-1)
      end
    end
  end
end
