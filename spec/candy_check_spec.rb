require "spec_helper"

describe CandyCheck do
  subject { CandyCheck }

  it "has a version" do
    _(subject::VERSION).wont_be_nil
  end
end
