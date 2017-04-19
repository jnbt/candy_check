require 'spec_helper'

describe CandyCheck::PlayStore::AuthorizationBuilder do
  subject { CandyCheck::PlayStore::AuthorizationBuilder.new(config) }

  describe 'key_file and key_secret' do
    include WithFixtures

    let(:config) do
      CandyCheck::PlayStore::Config.new(
        application_name: 'the_name',
        application_version: 'the_version',
        issuer: 'service-account@test_project.iam.gserviceaccount.com',
        key_file: fixture_path('play_store', 'dummy.p12'),
        key_secret: 'notasecret'
      )
    end

    it 'build authorization from a key file' do
      auth = subject.build_authorization
      auth.must_be_kind_of Signet::OAuth2::Client
      auth.issuer.must_equal 'service-account@test_project.iam' \
                             '.gserviceaccount.com'
    end
  end

  describe 'client_secrets' do
    include WithFixtures

    let(:config) do
      CandyCheck::PlayStore::Config.new(
        application_name: 'the_name',
        application_version: 'the_version',
        issuer: 'service-account@test_project.iam.gserviceaccount.com',
        secrets_file: fixture_path('play_store', 'client_secrets.json')
      )
    end

    it 'build authorization from a JSON file' do
      auth = subject.build_authorization
      auth.must_be_kind_of Signet::OAuth2::Client
      auth.issuer.must_equal 'service-account@test_project.iam' \
                             '.gserviceaccount.com'
    end
  end
end
