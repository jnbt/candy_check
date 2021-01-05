require 'spec_helper'

describe CandyCheck::AppStore::Config do
  subject { CandyCheck::AppStore::Config.new(attributes) }

  describe 'valid' do
    let(:attributes) do
      {
        environment: :sandbox
      }
    end

    it 'returns environment' do
      _(subject.environment).must_equal :sandbox
    end

    it 'checks for production?' do
      _(subject.production?).must_be_false

      other = CandyCheck::AppStore::Config.new(
        environment: :production
      )
      _(other.production?).must_be_true
    end
  end

  describe 'invalid' do
    let(:attributes) do
      {}
    end

    it 'needs an environment' do
      _(proc { subject }).must_raise ArgumentError
    end

    it 'needs an included environment' do
      attributes[:environment] = :invalid
      _(proc { subject }).must_raise ArgumentError
    end
  end
end
