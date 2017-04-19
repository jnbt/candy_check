require 'spec_helper'

describe CandyCheck::PlayStore::Config do
  subject { CandyCheck::PlayStore::Config.new(attributes) }

  let(:attributes) do
    {
      application_name: 'the_name',
      application_version: 'the_version',
      issuer: 'the_issuer'
    }
  end

  describe 'minimal attributes' do
    it 'initializes and validates correctly' do
      subject.application_name.must_equal 'the_name'
      subject.application_version.must_equal 'the_version'
      subject.issuer.must_equal 'the_issuer'
    end
  end

  describe 'key_file and key_secret' do
    let(:deprecated_attributes) do
      attributes.merge(
        key_file: 'the_key_file',
        key_secret: 'the_key_secret'
      )
    end

    it 'warns about deprecation' do
      config = nil
      proc {
        config = CandyCheck::PlayStore::Config.new(deprecated_attributes)
      }.must_output(nil, /key_file.*key_secret/m)
    end

    it 'doesnt uses client_secrets' do
      subject.use_client_secrets?.must_be_false
    end
  end

  describe 'cache_file' do
    let(:deprecated_attributes) do
      attributes.merge(
        cache_file: 'foo.txt'
      )
    end

    it 'warns about deprecation' do
      config = nil
      proc {
        config = CandyCheck::PlayStore::Config.new(deprecated_attributes)
      }.must_output(nil, /cache_file/)
    end
  end

  describe 'client_secrets' do
    include WithFixtures

    let(:attributes) do
      {
        application_name: 'the_name',
        application_version: 'the_version',
        issuer: 'the_issuer',
        secrets_file: fixture_path('play_store', 'client_secrets.json')
      }
    end

    it 'uses client_secrets' do
      subject.use_client_secrets?.must_be_true
    end
  end

  describe 'invalid attributes' do
    it 'needs application_name' do
      assert_raises_missing :application_name
    end

    it 'needs application_version' do
      assert_raises_missing :application_version
    end

    it 'needs issuer' do
      assert_raises_missing :issuer
    end

    private

    def assert_raises_missing(name)
      attributes.delete(name)
      proc do
        subject
      end.must_raise ArgumentError
    end
  end
end
