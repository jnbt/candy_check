require 'spec_helper'

describe CandyCheck::AppStore::PendingRenewalInfo do
  subject { CandyCheck::AppStore::PendingRenewalInfo.new(attributes) }

  let(:attributes) do
    {
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
    }
  end

  it 'returns the auto renew product_id' do
    _(subject.auto_renew_product_id).must_equal 'some_product'
  end

  it 'returns the auto renew status' do
    _(subject.auto_renew_status).must_equal 1
  end

  it 'returns the expiration intent' do
    _(subject.expiration_intent).must_equal 0
  end
  
  it 'returns the grace period expiration date' do
    expected = DateTime.new(2015, 1, 9, 11, 40, 46)
    _(subject.grace_period_expires_date).must_equal expected
  end

  it 'returns whether item is in billing retry period' do
    _(subject.is_in_billing_retry_period).must_equal 0
  end

  it 'returns the offer code reference name' do
    _(subject.offer_code_ref_name).must_equal 'some_offer_code_ref_name'
  end

  it 'returns the original transaction id' do
    _(subject.original_transaction_id).must_equal 'some_original_transaction_id'
  end

  it 'returns the price consent status' do
    _(subject.price_consent_status).must_equal 0
  end

  it 'returns the product id' do
    _(subject.product_id).must_equal 'some_product'
  end

  it 'returns the promotional offer id' do
    _(subject.promotional_offer_id).must_equal 'some_promotional_offer_id'
  end

  it 'returns raw attributes' do
    _(subject.attributes).must_be_same_as attributes
  end
end
