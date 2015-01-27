require 'spec_helper'
require 'candy_check/test_helper'

describe CandyCheck::TestHelper::AnswerList do
  subject { CandyCheck::TestHelper::AnswerList.new(failure_message) }
  let(:error_class) { CandyCheck::TestHelper::AnswerList::MissingAnswerError }
  let(:failure_message) { 'some_message' }

  it 'fails on empty list' do
    proc { subject.fetch }.must_raise error_class
  end

  it 'has a size' do
    subject.size.must_equal 0
    subject << 1
    subject.size.must_equal 1
    subject.fetch
    subject.size.must_equal 0
  end

  it 'implements Enumerable' do
    subject << 0
    subject << 1
    subject.each_with_index do |got, i|
      got.must_equal i
    end
  end

  it 'fetches answers from added ones' do
    subject << 1
    subject << 2
    subject.fetch.must_equal 1
    subject.fetch.must_equal 2
    proc { subject.fetch }.must_raise error_class
  end
end
