require "spec_helper"

describe CandyCheck::PlayStore::Config do
  subject { CandyCheck::PlayStore::Config.new(attributes) }

  let(:attributes) do
    { json_key_file: "/home/chris/Desktop/candy_check/key.json" }
  end

  describe "minimal attributes" do
    it "initializes and validates correctly" do
      subject.json_key_file.must_equal "/home/chris/Desktop/candy_check/key.json"
    end
  end

  describe "maximal attributes" do
    let(:attributes) do
      { json_key_file: "/home/chris/Desktop/candy_check/key.json" }
    end

    it "initializes and validates correctly" do
      subject.json_key_file.must_equal "/home/chris/Desktop/candy_check/key.json"
    end
  end

  describe "invalid attributes" do
    it "needs key_file" do
      assert_raises_missing :json_key_file
    end

    private

    def assert_raises_missing(name)
      attributes.delete(name)
      proc do
        subject
      end.must_raise ArgumentError
    end
  end
end
