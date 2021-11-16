require 'spec_helper'

describe CandyCheck::AppStore::ReceiptCollection do
  subject { CandyCheck::AppStore::ReceiptCollection.new(attributes, pending_renewal_infos) }

  let(:pending_renewal_infos) do
    [{
      "auto_renew_product_id"         => "some_product",
      "auto_renew_status"             => "1",
      "expiration_intent"             => "0",
      "grace_period_expires_date"     => '2015-01-09 11:40:46 Etc/GMT',
      "grace_period_expires_date_ms"  => '1420717246868',
      "grace_period_expires_date_pst" => '2015-01-09 03:40:46 America/Los_Angeles',
      "is_in_billing_retry_period"    => "0",
      "offer_code_ref_name"           => "some_offer_code_ref_name",
      "original_transaction_id"       => "some_original_transaction_id",
      "price_consent_status"          => "0",
      "product_id"                    => "some_product",
      "promotional_offer_id"          => "some_promotional_offer_id",
    }]
  end

  describe 'overdue subscription' do
    let(:attributes) do
      [{
        'expires_date' => '2014-04-15 12:52:40 Etc/GMT',
        'expires_date_pst' => '2014-04-15 05:52:40 America/Los_Angeles',
        'purchase_date' => '2014-04-14 12:52:40 Etc/GMT',
        'is_trial_period' => 'false'
      }, {
        'expires_date' => '2015-04-15 12:52:40 Etc/GMT',
        'expires_date_pst' => '2015-04-15 05:52:40 America/Los_Angeles',
        'purchase_date' => '2015-04-14 12:52:40 Etc/GMT',
        'is_trial_period' => 'false'
      }]
    end

    it 'is expired' do
      _(subject.expired?).must_be_true
    end

    it 'is not a trial' do
      _(subject.trial?).must_be_false
    end

    it 'has positive overdue days' do
      overdue = subject.overdue_days
      _(overdue).must_be_instance_of Integer
      assert overdue > 0
    end

    it 'has a last expires date' do
      expected = DateTime.new(2015, 4, 15, 12, 52, 40)
      _(subject.expires_at).must_equal expected
    end

    it 'is expired? at same point in time' do
      Timecop.freeze(Time.utc(2015, 4, 15, 12, 52, 40)) do
        _(subject.expired?).must_be_true
      end
    end

    it 'has an array of CandyCheck::AppStore::PendingRenewalInfo objects' do
      _(subject.pending_renewal_infos.first).must_be_instance_of CandyCheck::AppStore::PendingRenewalInfo
    end
  end

  describe 'unordered receipts' do
    let(:attributes) do
      [{
           'expires_date' => '2015-04-15 12:52:40 Etc/GMT',
           'expires_date_pst' => '2015-04-15 05:52:40 America/Los_Angeles',
           'purchase_date' => '2015-04-14 12:52:40 Etc/GMT',
           'is_trial_period' => 'false'
       }, {
           'expires_date' => '2014-04-15 12:52:40 Etc/GMT',
           'expires_date_pst' => '2014-04-15 05:52:40 America/Los_Angeles',
           'purchase_date' => '2014-04-14 12:52:40 Etc/GMT',
           'is_trial_period' => 'false'
       }]
    end

    it 'the expires date is the latest one in time' do
      expected = DateTime.new(2015, 4, 15, 12, 52, 40)
      _(subject.expires_at).must_equal expected
    end

  end

  describe 'unexpired trial subscription' do
    two_days_from_now = DateTime.now + 2

    let(:attributes) do
      [{
        'expires_date' => '2016-04-15 12:52:40 Etc/GMT',
        'purchase_date' => '2016-04-15 12:52:40 Etc/GMT',
        'is_trial_period' => 'true'
      }, {
        'expires_date' =>
          two_days_from_now.strftime('%Y-%m-%d %H:%M:%S Etc/GMT'),
        'purchase_date' => '2016-04-15 12:52:40 Etc/GMT',
        'is_trial_period' => 'true'
      }]
    end

    it 'has not expired' do
      _(subject.expired?).must_be_false
    end

    it 'it is a trial' do
      _(subject.trial?).must_be_true
    end

    it 'expires in two days' do
      _(subject.overdue_days).must_equal(-2)
    end
  end

end
