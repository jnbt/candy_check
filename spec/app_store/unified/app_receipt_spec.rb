require 'spec_helper'

describe CandyCheck::AppStore::Unified::AppReceipt do
  subject { CandyCheck::AppStore::Unified::AppReceipt.new(attributes) }

  let(:attributes) { JSON.parse(<<-RECEIPT) }
    {
      "bundle_id": "com.app.bundle_id",
      "application_version": "6",
      "receipt_creation_date": "2017-07-25 00:55:46 Etc/GMT",
      "expiration_date": "2018-07-25 00:55:46 Etc/GMT",
      "original_application_version": "1.0",
      "in_app": [
        {
          "transaction_id": "1",
          "purchase_date": "2017-04-24 00:55:46 Etc/GMT"
        },
        {
          "transaction_id": "3",
          "purchase_date": "2017-07-25 00:55:46 Etc/GMT"
        },
        {
          "transaction_id": "2",
          "purchase_date": "2017-06-24 00:55:46 Etc/GMT"
        }
      ]
    }
  RECEIPT

  it 'returns bundle_id' do
    subject.bundle_id.must_equal 'com.app.bundle_id'
  end

  it 'returns application_version' do
    subject.application_version.must_equal '6'
  end

  it 'returns original_application_version' do
    subject.original_application_version.must_equal '1.0'
  end

  it 'returns creation_date' do
    expected = DateTime.new(2017, 7, 25, 0, 55, 46)
    subject.creation_date.must_equal expected
  end

  it 'returns expiration_date' do
    expected = DateTime.new(2018, 7, 25, 0, 55, 46)
    subject.expiration_date.must_equal expected
  end

  it 'returns array of inapp receipts' do
    subject.in_app_receipts.size.must_equal 3
    receipt = subject.in_app_receipts.first
    receipt.must_be_instance_of CandyCheck::AppStore::Unified::InAppReceipt
  end
end
