require "spec_helper"

describe CandyCheck::CLI::Commands::PlayStore do
  include WithCommand
  subject { CandyCheck::CLI::Commands::PlayStore.new(package_name, product_id, token, "json_key_file" => json_key_file) }
  let(:package_name) { "my_package_name" }
  let(:product_id) { "my_product_id" }
  let(:token) { "my_token" }
  let(:json_key_file) { File.expand_path("../../fixtures/play_store/random_dummy_key.json", __dir__) }

  it "calls and outputs the verifier" do
    VCR.use_cassette("play_store/product_purchases/valid_but_not_consumed") do
      run_command!
      assert_equal "CandyCheck::PlayStore::ProductPurchases::ProductPurchase:", out.lines.first
      assert_equal CandyCheck::PlayStore::ProductPurchases::ProductPurchase, out.lines[1].class
    end
  end
end
