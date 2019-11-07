require "spec_helper"

describe CandyCheck::PlayStore::VerificationFailure do
  subject { CandyCheck::PlayStore::VerificationFailure.new(fake_error) }

  describe "denied" do
    let(:fake_error) do
      FakeError.new("401", "The current user has insufficient permissions")
    end

    it "returns the code" do
      subject.code.must_equal 401
    end

    it "returns the message" do
      subject.message.must_equal "The current user has insufficient permissions"
    end
  end

  describe "empty" do
    let(:fake_error) do
      FakeError.new(nil, nil)
    end

    it "returns an unknown code" do
      subject.code.must_equal(-1)
    end

    it "returns an unknown message" do
      subject.message.must_equal "Unknown error"
    end
  end

  FakeError = Struct.new(:status_code, :message)
end
