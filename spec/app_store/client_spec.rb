require 'spec_helper'

describe CandyCheck::AppStore::Client do
  let(:endpoint_url) { 'https://some.endpoint.com/verify' }
  let(:receipt_data) do
    'some_very_long_receipt_information_which_is_normaly_base64_encoded'
  end
  let(:password) do
    'some_secret_password'
  end
  let(:response) do
    '{
    "receipt": {
        "item_id": "521129812"
    },
    "status": 0
}'
  end
  let(:expected) do
    {
      'status' => 0,
      'receipt' => {
        'item_id' => '521129812'
      }
    }
  end

  subject { CandyCheck::AppStore::Client.new(endpoint_url) }

  describe 'valid response' do
    it 'sends JSON and parses the JSON response without a secret' do
      stub_endpoint
        .with(
          body: {
            'receipt-data' => receipt_data
          }
        )
        .to_return(
          body: response
        )
      result = subject.verify(receipt_data)
      result.must_equal expected
    end

    it 'sends JSON and parses the JSON response with a secret' do
      stub_endpoint
        .with(
          body: {
            'receipt-data' => receipt_data,
            'password'     => password
          }
        )
        .to_return(
          body: response
        )
      result = subject.verify(receipt_data, password)
      result.must_equal expected
    end
  end

  private

  def stub_endpoint
    stub_request(:post, endpoint_url)
  end
end
