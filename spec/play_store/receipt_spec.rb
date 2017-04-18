require 'spec_helper'

describe CandyCheck::PlayStore::Receipt do
  subject { CandyCheck::PlayStore::Receipt.new(attributes) }

  describe 'valid and non-consumed product' do
    let(:attributes) do
      {
        kind: 'androidpublisher#productPurchase',
        purchase_time_millis: 1_421_676_237_413,
        purchase_state: 0,
        consumption_state: 0,
        developer_payload: 'payload that gets stored and returned'
      }
    end

    it 'is valid?' do
      subject.valid?.must_be_true
    end

    it 'is not consumed' do
      subject.consumed?.must_be_false
    end

    it 'returns the purchase_state' do
      subject.purchase_state.must_equal 0
    end

    it 'returns the consumption_state' do
      subject.consumption_state.must_equal 0
    end

    it 'returns the developer_payload' do
      subject.developer_payload.must_equal \
        'payload that gets stored and returned'
    end

    it 'returns the kind' do
      subject.kind.must_equal \
        'androidpublisher#productPurchase'
    end

    it 'returns the purchase_time_millis' do
      subject.purchase_time_millis.must_equal 1_421_676_237_413
    end

    it 'returns the purchased_at' do
      expected = DateTime.new(2015, 1, 19, 14, 3, 57)
      subject.purchased_at.must_equal expected
    end
  end

  describe 'valid and consumed product' do
    let(:attributes) do
      {
        kind: 'androidpublisher#productPurchase',
        purchase_time_millis: 1_421_676_237_413,
        purchase_state: 0,
        consumption_state: 1,
        developer_payload: 'payload that gets stored and returned'
      }
    end

    it 'is valid?' do
      subject.valid?.must_be_true
    end

    it 'is consumed?' do
      subject.consumed?.must_be_true
    end
  end

  describe 'non-valid product' do
    let(:attributes) do
      {
        kind: 'androidpublisher#productPurchase',
        purchase_time_millis: 1_421_676_237_413,
        purchase_state: 1,
        consumption_state: 0,
        developer_payload: 'payload that gets stored and returned'
      }
    end

    it 'is valid?' do
      subject.valid?.must_be_false
    end
  end
end
