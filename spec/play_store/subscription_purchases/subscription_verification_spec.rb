require "spec_helper"

describe CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionVerification do
  subject do
    CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionVerification.new(
      package_name: package_name,
      subscription_id: subscription_id,
      token: token,
      authorization: authorization,
    )
  end

  let(:json_key_file) { File.expand_path("../../fixtures/play_store/random_dummy_key.json", __dir__) }
  let(:authorization) { CandyCheck::PlayStore.authorization(json_key_file) }

  let(:package_name) { "my_package_name" }
  let(:subscription_id) { "my_subscription_id" }
  let(:token) { "my_token" }

  describe "valid" do
    it "returns a subscription" do
      VCR.use_cassette("play_store/subscription_purchases/valid_but_expired") do
        result = subject.call!

        result.must_be_instance_of CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase
        result.expired?.must_be_true
      end
    end
  end

  describe "failure" do
    it "returns a verification failure" do
      VCR.use_cassette("play_store/subscription_purchases/permission_denied") do
        result = subject.call!
        result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
        result.code.must_equal 401
      end
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
