require "spec_helper"

describe CandyCheck::PlayStore::VerificationFailure do
  subject { CandyCheck::PlayStore::VerificationFailure.new(fake_error) }

  let(:fake_error_class) do
    Struct.new(:status_code, :message)
  end

  describe "denied" do
    let(:fake_error) do
      fake_error_class.new("401", "The current user has insufficient permissions")
    end

    it "returns the code" do
      _(subject.code).must_equal 401
    end

    it "returns the message" do
      _(subject.message).must_equal "The current user has insufficient permissions"
    end
  end

  describe "empty" do
    let(:fake_error) do
      fake_error_class.new(nil, nil)
    end

    it "returns an unknown code" do
      _(subject.code).must_equal(-1)
    end

    it "returns an unknown message" do
      _(subject.message).must_equal "Unknown error"
    end
  end
end
