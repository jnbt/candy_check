require 'spec_helper'

describe CandyCheck::PlayStore::Client do
  include WithTempFile
  include WithFixtures

  with_temp_file :cache_file

  subject { CandyCheck::PlayStore::Client.new(config) }

  let(:config) do
    CandyCheck::PlayStore::ClientConfig.new(
      application_name: 'demo_app',
      application_version: '1.0',
      issuer: 'test_issuer',
      key_file: fixture_path('play_store', 'dummy.p12'),
      cache_file: cache_file_path,
      key_secret: 'notasecret'
    )
  end

  describe 'discovery' do
    describe 'w/o cache file' do
      it 'boot loads and dumps discovery file' do
        mock_discovery!('discovery.txt')
        mock_authorize!('auth_success.txt')
        subject.boot!
        File.exist?(cache_file_path).must_be_true
      end

      it 'fails if discovery fails' do
        mock_discovery!('empty.txt')
        proc { subject.boot! }.must_raise \
          CandyCheck::PlayStore::Client::DiscoveryError
      end
    end

    describe 'with cache file' do
      let(:cache_file_path) { fixture_path('play_store', 'api_cache.dump') }

      it 'loads the discovery from cache file' do
        mock_authorize!('auth_success.txt')
        subject.boot!
      end
    end
  end

  it 'fails if authentication fails' do
    mock_discovery!('discovery.txt')
    mock_authorize!('auth_failure.txt')
    proc { subject.boot! }.must_raise Signet::AuthorizationError
  end

  it 'returns the products call result\'s data even if it is a failure' do
    bootup!

    mock_request!('products_failure.txt')
    result = subject.verify('the_package', 'the_id', 'the_token')
    result.must_be_instance_of \
      Google::APIClient::Schema::Androidpublisher::V2::ProductPurchase
  end

  it 'returns the products call result\'s data for a successful call' do
    bootup!
    mock_request!('products_success.txt')
    result = subject.verify('the_package', 'the_id', 'the_token')
    result.must_be_instance_of \
      Google::APIClient::Schema::Androidpublisher::V2::ProductPurchase
  end

  private

  def bootup!
    mock_discovery!('discovery.txt')
    mock_authorize!('auth_success.txt')
    subject.boot!
  end

  def mock_discovery!(file)
    stub_request(:get, 'https://www.googleapis.com/discovery/' \
                       'v1/apis/androidpublisher/v2/rest')
      .to_return(fixture_content('play_store', file))
  end

  def mock_authorize!(file)
    stub_request(:post, 'https://accounts.google.com/o/oauth2/token')
      .to_return(fixture_content('play_store', file))
  end

  def mock_request!(file)
    stub_request(:get, 'https://www.googleapis.com/androidpublisher/v2/' \
      'applications/the_package/purchases/products/the_id/tokens/the_token')
      .to_return(fixture_content('play_store', file))
  end
end
