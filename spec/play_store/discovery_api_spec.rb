require 'spec_helper'

describe CandyCheck::PlayStore::Client do
  include WithTempFile
  include WithFixtures

  with_temp_file :cache_file

  subject do
    CandyCheck::PlayStore::DiscoveryApi.new(
      repository: repository
    )
  end
  let(:repository) { MiniTest::Mock.new }
  let(:api_client) { MiniTest::Mock.new }
  let(:rpc_fake_valid) do
    OpenStruct.new(
      purchases: OpenStruct.new(
        products: OpenStruct.new(
          get: true
        )
      )
    )
  end
  let(:rpc_fake_invalid) do
    OpenStruct.new(broken: true)
  end

  describe 'rpc' do
    describe 'w/o cache file' do
      it 'writes to cache and returns rpc' do
        api_client.expect(
          :discovered_api, rpc_fake_valid, %w(androidpublisher v2)
        )
        repository.expect(:load, nil)
        repository.expect(:save, nil, [rpc_fake_valid])

        rpc = subject.rpc(api_client: api_client)

        assert_equal rpc, rpc_fake_valid
        assert_mock repository
        assert_mock api_client
      end

      it 'fails rpc validation' do
        api_client.expect(
          :discovered_api, rpc_fake_invalid, %w(androidpublisher v2)
        )
        repository.expect(:load, nil)

        proc { subject.rpc(api_client: api_client) }.must_raise \
          CandyCheck::PlayStore::DiscoveryApi::Error

        assert_mock repository
        assert_mock api_client
      end
    end

    describe 'with cache file' do
      let(:cache_file_path) { fixture_path('play_store', 'api_cache.dump') }

      it 'loads the discovery from cache file' do
        repository.expect(:load, rpc_fake_valid)

        rpc = subject.rpc(api_client: api_client)

        assert_equal rpc, rpc_fake_valid
        assert_mock repository
      end
    end
  end
end
