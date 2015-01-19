require 'spec_helper'

describe CandyCheck::PlayStore::ClientConfig do
  subject { CandyCheck::PlayStore::ClientConfig.new(attributes) }

  let(:attributes) do
    {
      application_name: 'the_name',
      application_version: 'the_version',
      issuer: 'the_issuer',
      key_file: 'the_key_file',
      key_secret: 'the_key_secret'
    }
  end

  describe 'minimal attributes' do
    it 'initializes and validates correctly' do
      subject.application_name.must_equal 'the_name'
      subject.application_version.must_equal 'the_version'
      subject.issuer.must_equal 'the_issuer'
      subject.key_file.must_equal 'the_key_file'
      subject.key_secret.must_equal 'the_key_secret'
    end
  end

  describe 'maximal attributes' do
    let(:attributes) do
      {
        application_name: 'the_name',
        application_version: 'the_version',
        issuer: 'the_issuer',
        key_file: 'the_key_file',
        key_secret: 'the_key_secret',
        cache_file: 'the_cache_file'
      }
    end

    it 'initializes and validates correctly' do
      subject.application_name.must_equal 'the_name'
      subject.application_version.must_equal 'the_version'
      subject.issuer.must_equal 'the_issuer'
      subject.key_file.must_equal 'the_key_file'
      subject.key_secret.must_equal 'the_key_secret'
      subject.cache_file.must_equal 'the_cache_file'
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

    it 'needs key_file' do
      assert_raises_missing :key_file
    end

    it 'needs key_secret' do
      assert_raises_missing :key_secret
    end

    private

    def assert_raises_missing(name)
      attributes.delete(name)
      proc do
        subject
      end.must_raise ArgumentError
    end
  end

  describe 'p12 certificate' do
    include WithFixtures

    let(:attributes) do
      {
        application_name: 'the_name',
        application_version: 'the_version',
        issuer: 'the_issuer',
        key_file: fixture_path('play_store', 'dummy.p12'),
        key_secret: 'notasecret'
      }
    end

    it 'load the api_key from a file' do
      subject.api_key.wont_be_nil
    end
  end
end
