require "spec_helper"

describe CandyCheck::PlayStore::Verifier do
  subject { CandyCheck::PlayStore::Verifier.new(authorization: authorization) }

  let(:package_name) { "my_package_name" }
  let(:product_id) { "my_product_id" }
  let(:token) { "my_token" }

  let(:json_key_file) { File.expand_path("../fixtures/play_store/random_dummy_key.json", __dir__) }
  let(:authorization) { CandyCheck::PlayStore.authorization(json_key_file) }

  it "verifies a product purchase" do
    VCR.use_cassette("play_store/product_purchases/valid_but_not_consumed") do
      result = subject.verify_product_purchase(package_name: package_name, product_id: product_id, token: token)
      result.must_be_instance_of CandyCheck::PlayStore::ProductPurchases::ProductPurchase
      result.valid?.must_be_true
      result.consumed?.must_be_false
    end
  end
end
