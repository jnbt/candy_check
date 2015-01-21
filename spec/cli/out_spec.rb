require 'spec_helper'

describe CandyCheck::CLI::Out do
  subject { CandyCheck::CLI::Out.new(out) }
  let(:out) { StringIO.new }

  it 'defaults to use STDOUT' do
    CandyCheck::CLI::Out.new.out.must_be_same_as $stdout
  end

  it 'holds the outlet' do
    subject.out.must_be_same_as out
  end

  it 'prints to outlet' do
    subject.print 'some text'
    subject.print 'another line'
    close
    out.readlines.must_equal [
      "some text\n",
      "another line\n"
    ]
  end

  it 'pretty prints to outlet' do
    subject.pretty dummy: 1
    subject.pretty [1, 2, 3]
    close
    out.readlines.must_equal [
      "{:dummy=>1}\n",
      "[1, 2, 3]\n"
    ]
  end

  private

  def close
    out.flush
    out.rewind
  end
end
