# frozen_string_literal: true

require 'spec_helper'

describe CandyCheck::AppStore::ReceiptCollection do
  subject { CandyCheck::AppStore::ReceiptCollection.new(attributes) }

  describe 'overdue subscription' do
    let(:attributes) do
      [{
        'expires_date' => '2014-04-15 12:52:40 Etc/GMT',
        'expires_date_pst' => '2014-04-15 05:52:40 America/Los_Angeles',
        'is_trial_period' => 'false'
      }, {
        'expires_date' => '2015-04-15 12:52:40 Etc/GMT',
        'expires_date_pst' => '2015-04-15 05:52:40 America/Los_Angeles',
        'is_trial_period' => 'false'
      }]
    end

    it 'is expired' do
      subject.expired?.must_be_true
    end

    it 'is not a trial' do
      subject.trial?.must_be_false
    end

    it 'has positive overdue days' do
      overdue = subject.overdue_days
      overdue.is_a?(Integer).must_be_true
      assert overdue > 0
    end

    it 'has a last expires date' do
      expected = DateTime.new(2015, 4, 15, 12, 52, 40)
      subject.expires_at.must_equal expected
    end

    it 'is expired? at same pointin time' do
      Timecop.freeze(Time.utc(2015, 4, 15, 12, 52, 40)) do
        subject.expired?.must_be_true
      end
    end
  end

  describe 'unexpired trial subscription' do
    two_days_from_now = DateTime.now + 2

    let(:attributes) do
      [{
        'expires_date' => '2016-04-15 12:52:40 Etc/GMT',
        'is_trial_period' => 'true'
      }, {
        'expires_date' =>
          two_days_from_now.strftime('%Y-%m-%d %H:%M:%S Etc/GMT'),
        'is_trial_period' => 'true'
      }]
    end

    it 'has not expired' do
      subject.expired?.must_be_false
    end

    it 'it is a trial' do
      subject.trial?.must_be_true
    end

    it 'expires in two days' do
      subject.overdue_days.must_equal(-2)
    end
  end
end
