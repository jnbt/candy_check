require 'spec_helper'
require 'candy_check/test_helper'

describe CandyCheck::TestHelper::AppStore::FakeVerifier do
  subject { CandyCheck::TestHelper::AppStore::FakeVerifier.new }
  let(:answers_error_class) do
    CandyCheck::TestHelper::AnswerList::MissingAnswerError
  end
  let(:recorder_error_class) do
    CandyCheck::TestHelper::CallRecorder::ExpectationError
  end
  let(:receipt) { 'some-receipt' }
  let(:secret) { 'some-secret' }

  it 'must hold a recorder and answers' do
    subject.recorder.must_be_instance_of CandyCheck::TestHelper::CallRecorder
    subject.answers.must_be_instance_of CandyCheck::TestHelper::AnswerList
  end

  it 'can hold a config' do
    config = Object.new
    subject = CandyCheck::TestHelper::AppStore::FakeVerifier.new(config)
    subject.config.must_be_same_as config
  end

  it 'raises if no answers are defined' do
    proc { subject.verify(receipt) }.must_raise answers_error_class
  end

  it 'raises on assert_calls!' do
    subject.stub_receipt!
    subject.verify(receipt)
    proc do
      subject.assert_calls!(['wrong'])
    end.must_raise recorder_error_class

    proc do
      subject.assert_calls!([receipt, 'wrong'])
    end.must_raise recorder_error_class

    proc do
      subject.assert_calls!([receipt], ['wrong'])
    end.must_raise recorder_error_class
  end

  it 'records all verify calls and returns predefined answers' do
    subject.stub_receipt!
    subject.verify(receipt).valid?.must_be_true
    subject.stub_failure!
    subject.verify(receipt, secret).code.wont_be_nil

    recoreded = subject.recorder.to_a

    recoreded.size.must_equal 2
    recoreded.first.receipt_data.must_equal receipt
    recoreded.first.secret.must_be_nil

    recoreded.last.receipt_data.must_equal receipt
    recoreded.last.secret.must_equal secret
  end

  it 'fetches receipts with default attributes' do
    got = subject.fetch_receipt
    got.must_be_instance_of CandyCheck::AppStore::Receipt
    got.transaction_id.wont_be_nil
    got.purchase_date.wont_be_nil
    got.original_purchase_date.wont_be_nil
  end

  it 'fetches receipts with merged attributes' do
    got = subject.fetch_receipt('transaction_id' => 'merged')
    got.must_be_instance_of CandyCheck::AppStore::Receipt
    got.transaction_id.must_equal 'merged'
    got.purchase_date.wont_be_nil
    got.original_purchase_date.wont_be_nil
  end

  it 'fetches verficication_failure with default code' do
    subject.fetch_verification_failure.code.must_equal 21_000
  end

  it 'fetches verficication_failure with custom code' do
    subject.fetch_verification_failure(21_001).code.must_equal 21_001
  end

  it 'stub_receipt! w/o arguments' do
    subject.stub_receipt!
    subject.answers.size.must_equal 1
    subject.answers.first.transaction_id.wont_be_nil
  end

  it 'stub_receipt! from a hash' do
    subject.stub_receipt!('transaction_id' => 'merged')
    subject.answers.size.must_equal 1
    subject.answers.first.transaction_id.must_equal 'merged'
  end

  it 'stub_receipt! from any object' do
    obj = Object.new
    subject.stub_receipt!(obj)
    subject.answers.size.must_equal 1
    subject.answers.first.must_be_same_as obj
  end

  it 'stub_failure! w/o arguments' do
    subject.stub_failure!
    subject.answers.size.must_equal 1
    subject.answers.first.code.wont_be_nil
  end

  it 'stub_failure! from a code' do
    subject.stub_failure!(21_001)
    subject.answers.size.must_equal 1
    subject.answers.first.code.must_equal 21_001
  end

  it 'stub_failure! from a code' do
    obj = Object.new
    subject.stub_failure!(obj)
    subject.answers.size.must_equal 1
    subject.answers.first.must_be_same_as obj
  end
end
