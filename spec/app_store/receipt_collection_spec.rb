require "spec_helper"

describe CandyCheck::AppStore::ReceiptCollection do
  subject { CandyCheck::AppStore::ReceiptCollection.new(attributes) }

  describe "overdue subscription" do
    let(:attributes) do
      [{
        "expires_date" => "2014-04-15 12:52:40 Etc/GMT",
        "expires_date_pst" => "2014-04-15 05:52:40 America/Los_Angeles",
        "purchase_date" => "2014-04-14 12:52:40 Etc/GMT",
        "is_trial_period" => "false",
      }, {
        "expires_date" => "2015-04-15 12:52:40 Etc/GMT",
        "expires_date_pst" => "2015-04-15 05:52:40 America/Los_Angeles",
        "purchase_date" => "2015-04-14 12:52:40 Etc/GMT",
        "is_trial_period" => "false",
      }]
    end

    it "is expired" do
      _(subject.expired?).must_be_true
    end

    it "is not a trial" do
      _(subject.trial?).must_be_false
    end

    it "has positive overdue days" do
      overdue = subject.overdue_days
      _(overdue).must_be_instance_of Integer
      assert overdue > 0
    end

    it "has a last expires date" do
      expected = DateTime.new(2015, 4, 15, 12, 52, 40)
      _(subject.expires_at).must_equal expected
    end

    it "is expired? at same pointin time" do
      Timecop.freeze(Time.utc(2015, 4, 15, 12, 52, 40)) do
        _(subject.expired?).must_be_true
      end
    end
  end

  describe "unordered receipts" do
    let(:attributes) do
      [{
        "expires_date" => "2015-04-15 12:52:40 Etc/GMT",
        "expires_date_pst" => "2015-04-15 05:52:40 America/Los_Angeles",
        "purchase_date" => "2015-04-14 12:52:40 Etc/GMT",
        "is_trial_period" => "false",
      }, {
        "expires_date" => "2014-04-15 12:52:40 Etc/GMT",
        "expires_date_pst" => "2014-04-15 05:52:40 America/Los_Angeles",
        "purchase_date" => "2014-04-14 12:52:40 Etc/GMT",
        "is_trial_period" => "false",
      }]
    end

    it "the expires date is the latest one in time" do
      expected = DateTime.new(2015, 4, 15, 12, 52, 40)
      _(subject.expires_at).must_equal expected
    end
  end

  describe "unexpired trial subscription" do
    two_days_from_now = DateTime.now + 2

    let(:attributes) do
      [{
        "expires_date" => "2016-04-15 12:52:40 Etc/GMT",
        "purchase_date" => "2016-04-15 12:52:40 Etc/GMT",
        "is_trial_period" => "true",
      }, {
        "expires_date" =>
          two_days_from_now.strftime("%Y-%m-%d %H:%M:%S Etc/GMT"),
        "purchase_date" => "2016-04-15 12:52:40 Etc/GMT",
        "is_trial_period" => "true",
      }]
    end

    it "has not expired" do
      _(subject.expired?).must_be_false
    end

    it "it is a trial" do
      _(subject.trial?).must_be_true
    end

    it "expires in two days" do
      _(subject.overdue_days).must_equal(-2)
    end
  end
end
