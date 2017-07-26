require 'spec_helper'

describe CandyCheck::AppStore::Unified::VerifiedResponse do
  subject { CandyCheck::AppStore::Unified::VerifiedResponse.new(response) }

  describe 'when response does not include a subscription' do
    let(:response) do
      {
        'status' => 0,
        'environment' => 'Production',
        'receipt' => {
          'bundle_id'                    => 'com.app.bundle_id',
          'application_version'          => '6',
          'receipt_creation_date'        => '2017-07-25 00:55:46 Etc/GMT',
          'original_application_version' => '1.0',
          'in_app'                       => [
            {
              'quantity'                 => '1',
              'product_id'               => 'com.app.product_id',
              'transaction_id'           => '1000800359115195',
              'original_transaction_id'  => '1000800359115195',
              'purchase_date'            => '2017-12-14 16:54:33 Etc/GMT',
              'original_purchase_date'   => '2017-12-14 16:29:35 Etc/GMT'
            }
          ]
        }
      }
    end

    let(:app_receipt_class) { CandyCheck::AppStore::Unified::AppReceipt }

    it '#subscription?' do
      subject.subscription?.must_be_false
    end

    it '#receipt' do
      subject.receipt.must_be_instance_of(app_receipt_class)
    end

    it '#latest_receipt_info' do
      subject.latest_receipt_info.must_be :empty?
    end

    it '#pending_renewal_info' do
      subject.pending_renewal_info.must_be :empty?
    end

    it '#latest_transaction' do
      subject.latest_transaction.must_be_nil
    end

    it '#expires_at' do
      subject.expires_at.must_be_nil
    end

    it '#pending_renewal_transaction' do
      subject.pending_renewal_transaction.must_be_nil
    end

    it '#expired?' do
      subject.expired?.must_be_false
    end

    it '#trial?' do
      subject.trial?.must_be_false
    end

    it '#canceled?' do
      subject.canceled?.must_be_false
    end

    it '#will_renew?' do
      subject.will_renew?.must_be_false
    end

    it '#in_billing_retry_period?' do
      subject.in_billing_retry_period?.must_be_false
    end
  end

  describe 'when respose includes a subscription' do
    let(:response) do
      {
        'status' => 0,
        'environment' => 'Production',
        'receipt' => {
          'bundle_id'                    => 'com.app.bundle_id',
          'application_version'          => '6',
          'receipt_creation_date'        => '2017-07-25 00:55:46 Etc/GMT',
          'original_application_version' => '1.0',
          'in_app'                       => [
            {
              'quantity'                 => '1',
              'product_id'               => 'com.app.product_id',
              'transaction_id'           => '1000800359115195',
              'original_transaction_id'  => '1000800359115195',
              'purchase_date'            => '2017-12-14 16:54:33 Etc/GMT',
              'original_purchase_date'   => '2017-12-14 16:29:35 Etc/GMT',
              'expires_date'             => '2017-12-14 16:59:33 Etc/GMT',
              'web_order_line_item_id'   => '1000000037215974',
              'is_trial_period'          => 'false',
              'is_in_intro_offer_period' => 'false'
            }
          ]
        },
        'latest_receipt_info' => [
          {
            'quantity'                 => '1',
            'product_id'               => 'com.app.product_id',
            'transaction_id'           => '1000800359115195',
            'original_transaction_id'  => '1000800359115195',
            'purchase_date'            => '2017-12-14 16:54:33 Etc/GMT',
            'original_purchase_date'   => '2017-12-14 16:29:35 Etc/GMT',
            'expires_date'             => '2017-12-14 16:59:33 Etc/GMT',
            'web_order_line_item_id'   => '1000000037215974',
            'is_trial_period'          => 'false',
            'is_in_intro_offer_period' => 'false'
          },
          {
            'quantity'                 => '1',
            'product_id'               => 'com.app.product_id',
            'transaction_id'           => '1000000359846977',
            'original_transaction_id'  => '1000800359115195',
            'purchase_date'            => '2017-12-15 08:17:54 Etc/GMT',
            'original_purchase_date'   => '2017-12-14 16:29:35 Etc/GMT',
            'expires_date'             => '2017-12-15 08:22:54 Etc/GMT',
            'web_order_line_item_id'   => '1000000037216020',
            'is_trial_period'          => 'false',
            'is_in_intro_offer_period' => 'false'
          }
        ],
        'latest_receipt' => 'base 64',
        'pending_renewal_info' => [
          {
            'expiration_intent'          => '4',
            'auto_renew_product_id'      => 'com.app.product_id',
            'original_transaction_id'    => '1000800359115195',
            'is_in_billing_retry_period' => '0',
            'product_id'                 => 'com.app.product_id',
            'auto_renew_status'          => '0'
          }
        ]
      }
    end

    let(:app_receipt_class) { CandyCheck::AppStore::Unified::AppReceipt }
    let(:in_app_class) { CandyCheck::AppStore::Unified::InAppReceipt }

    it '#subscription?' do
      subject.subscription?.must_be_true
    end

    it '#receipt' do
      subject.receipt.must_be_instance_of(app_receipt_class)
    end

    it '#latest_receipt_info' do
      subject.latest_receipt_info.size.must_equal 2
      subject.latest_receipt_info.last.must_be_instance_of(in_app_class)
    end

    it '#pending_renewal_info' do
      subject.pending_renewal_info.size.must_equal 1
      subject.latest_receipt_info.last.must_be_instance_of(in_app_class)
    end

    it '#latest_transaction' do
      subject.latest_transaction.must_be_instance_of(in_app_class)
      subject.latest_transaction.transaction_id.must_equal '1000000359846977'
    end

    it '#expires_at' do
      expected = DateTime.new(2017, 12, 15, 8, 22, 54)
      subject.expires_at.must_equal expected
    end

    it '#pending_renewal_transaction' do
      subject.pending_renewal_transaction.must_be_instance_of(in_app_class)
      subject
        .pending_renewal_transaction.is_in_billing_retry_period.must_equal 0
    end

    describe '#expired?' do
      describe 'when expired' do
        it { subject.expired?.must_be_true }
      end

      describe 'when not expired' do
        around do |example|
          Timecop.freeze(DateTime.new(2017, 10, 12, 8, 20, 45)) { example.call }
        end

        it { subject.expired?.must_be_false }
      end
    end

    describe '#trial?' do
      describe 'when trial' do
        before do
          response['latest_receipt_info'].last['is_trial_period'] = 'true'
        end

        it { subject.trial?.must_be_true }
      end

      describe 'when not trial' do
        it { subject.trial?.must_be_false }
      end
    end

    describe '#canceled?' do
      describe 'when canceled' do
        before do
          response['latest_receipt_info'].last['cancellation_date'] =
            '2017-12-15 16:59:33 Etc/GMT'
        end

        it { subject.canceled?.must_be_true }
      end

      describe 'when not canceled' do
        it { subject.canceled?.must_be_false }
      end
    end

    describe '#will_renew?' do
      describe 'when auto_renew disabled' do
        it { subject.will_renew?.must_be_false }
      end

      describe 'when auto_renew enabled' do
        before do
          response['pending_renewal_info'].last['auto_renew_status'] = '1'
        end

        it { subject.will_renew?.must_be_true }
      end
    end

    describe '#in_billing_retry_period?' do
      describe 'when Apple still attempting to renew the subscription' do
        before do
          response['pending_renewal_info'].last['is_in_billing_retry_period'] =
            '1'
        end

        it { subject.in_billing_retry_period?.must_be_true }
      end

      describe 'when Apple do not attempting to renew the subscription' do
        it { subject.in_billing_retry_period?.must_be_false }
      end
    end
  end
end
