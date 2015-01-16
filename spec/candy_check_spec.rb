require 'spec_helper'

describe CandyCheck do
  subject { CandyCheck }

  it 'has a version' do
    subject::VERSION.wont_be_nil
  end
  it 'has a config' do
    subject.config.must_be_instance_of CandyCheck::Config
  end
  it 'allows configuration' do
    c = subject.configure do |config|
      config.test_value = 1
    end
    subject.config.test_value.must_equal 1
    c.must_be_same_as(subject.config)
  end
end
