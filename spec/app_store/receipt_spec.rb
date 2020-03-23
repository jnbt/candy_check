require 'spec_helper'

describe CandyCheck::AppStore::Receipt do
  subject { CandyCheck::AppStore::Receipt.new(attributes) }

  let(:attributes) do
    {
      'original_purchase_date_pst' => '2015-01-08 03:40:46' \
                                      ' America/Los_Angeles',
      'purchase_date_ms'           => '1420803646868',
      'unique_identifier'          => 'some_uniq_identifier_from_apple' \
                                      '_for_this',
      'original_transaction_id'    => 'some_original_transaction_id',
      'bvrs'                       => '2.0',
      'transaction_id'             => 'some_transaction_id',
      'quantity'                   => '1',
      'unique_vendor_identifier'   => '00000000-1111-2222-3333-' \
                                      '444444444444',
      'item_id'                    => 'some_item_id',
      'product_id'                 => 'some_product',
      'purchase_date'              => '2015-01-09 11:40:46 Etc/GMT',
      'original_purchase_date'     => '2015-01-08 11:40:46 Etc/GMT',
      'purchase_date_pst'          => '2015-01-09 03:40:46' \
                                      ' America/Los_Angeles',
      'bid'                        => 'some.test.app',
      'original_purchase_date_ms'  => '1420717246868',
      'expires_date'               => '2016-06-09 13:59:40 Etc/GMT',
      'is_trial_period'            => 'false'
    }
  end

  describe 'valid transaction' do
    it 'is valid' do
      subject.valid?.must_be_true
    end

    it 'returns the item\'s product_id' do
      subject.product_id.must_equal 'some_product'
    end

    it 'returns the quantity' do
      subject.quantity.must_equal 1
    end

    it 'returns the purchase date' do
      expected = DateTime.new(2015, 1, 9, 11, 40, 46)
      subject.purchase_date.must_equal expected
    end

    it 'returns the original purchase date' do
      expected = DateTime.new(2015, 1, 8, 11, 40, 46)
      subject.original_purchase_date.must_equal expected
    end

    it 'returns the transaction id' do
      subject.transaction_id.must_equal 'some_transaction_id'
    end

    it 'returns the original transaction id' do
      subject.original_transaction_id.must_equal 'some_original_transaction_id'
    end

    it 'return nil for cancellation date' do
      subject.cancellation_date.must_be_nil
    end

    it 'returns raw attributes' do
      subject.attributes.must_be_same_as attributes
    end

    it 'returns the subscription expiration date' do
      expected = DateTime.new(2016, 6, 9, 13, 59, 40)
      subject.expires_date.must_equal expected
    end

    it 'returns the trial status' do
      subject.is_trial_period.must_be_false
    end
  end

  describe 'valid transaction' do
    before do
      attributes['cancellation_date'] = '2015-01-12 11:40:46 Etc/GMT'
    end

    it 'isn\'t valid' do
      subject.valid?.must_be_false
    end

    it 'return nil for cancellation date' do
      expected = DateTime.new(2015, 1, 12, 11, 40, 46)
      subject.cancellation_date.must_equal expected
    end
  end
end
