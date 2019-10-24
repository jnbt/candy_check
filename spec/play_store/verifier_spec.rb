require "spec_helper"

describe CandyCheck::PlayStore::Verifier do
  subject { CandyCheck::PlayStore::Verifier.new(authorization: authorization) }

  let(:package_name) { "my_package_name" }
  let(:product_id) { "my_product_id" }
  let(:subscription_id) { "my_subscription_id" }
  let(:token) { "my_token" }

  let(:json_key_file) { File.expand_path("../fixtures/play_store/random_dummy_key.json", __dir__) }
  let(:authorization) { CandyCheck::PlayStore.authorization(json_key_file) }

  describe "product purchases" do
    it "verifies a product purchase" do
      VCR.use_cassette("play_store/product_purchases/valid_but_not_consumed") do
        result = subject.verify_product_purchase(package_name: package_name, product_id: product_id, token: token)
        result.must_be_instance_of CandyCheck::PlayStore::ProductPurchases::ProductPurchase
        result.valid?.must_be_true
        result.consumed?.must_be_false
      end
    end

    it "can return a product purchase verification failure" do
      VCR.use_cassette("play_store/product_purchases/permission_denied") do
        result = subject.verify_product_purchase(package_name: package_name, product_id: product_id, token: token)
        result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      end
    end
  end

  describe "subscription purchases" do
    it "verifies a subscription purchase" do
      VCR.use_cassette("play_store/subscription_purchases/valid_but_expired") do
        result = subject.verify_subscription_purchase(package_name: package_name, subscription_id: subscription_id, token: token)
        result.must_be_instance_of CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase
      end
    end

    it "can return a subscription purchase verification failure" do
      VCR.use_cassette("play_store/subscription_purchases/permission_denied") do
        result = subject.verify_subscription_purchase(package_name: package_name, subscription_id: subscription_id, token: token)
        result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      end
    end
  end
end
