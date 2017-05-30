# frozen_string_literal: true

require 'spec_helper'

describe CandyCheck::PlayStore::DiscoveryRepository do
  subject { CandyCheck::PlayStore::DiscoveryRepository.new(discovery_path) }

  let(:data) do
    { 'demo' => 1 }
  end

  describe 'empty file path' do
    let(:discovery_path) { nil }

    it 'returns nil for nil path' do
      subject.load.must_be_nil
    end

    it 'does not save' do
      subject.save(data)
    end
  end

  describe 'valid file path' do
    include WithTempFile
    with_temp_file :discovery

    it 'saves and loads the file content' do
      subject.save(data)
      subject.load.must_equal data
    end
  end
end
