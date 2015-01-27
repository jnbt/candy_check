require 'spec_helper'
require 'candy_check/test_helper'

describe CandyCheck::TestHelper::PlayStore::FakeVerifier do
  subject { CandyCheck::TestHelper::PlayStore::FakeVerifier.new }
  let(:answers_error_class) do
    CandyCheck::TestHelper::AnswerList::MissingAnswerError
  end
  let(:recorder_error_class) do
    CandyCheck::TestHelper::CallRecorder::ExpectationError
  end
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }

  it 'must hold a recorder and answers' do
    subject.recorder.must_be_instance_of CandyCheck::TestHelper::CallRecorder
    subject.answers.must_be_instance_of CandyCheck::TestHelper::AnswerList
  end

  it 'can hold a config' do
    config = Object.new
    subject = CandyCheck::TestHelper::PlayStore::FakeVerifier.new(config)
    subject.config.must_be_same_as config
  end

  it 'raises if no answers are defined' do
    proc do
      subject.verify(package, product_id, token)
    end.must_raise answers_error_class
  end

  it 'raises on assert_calls!' do
    subject.stub_receipt!
    subject.verify(package, product_id, token)
    proc do
      subject.assert_calls!(%w(a b c))
    end.must_raise recorder_error_class

    proc do
      subject.assert_calls!([package, product_id, 'wrong'])
    end.must_raise recorder_error_class

    proc do
      subject.assert_calls!(%w(a b c), %(c d e))
    end.must_raise recorder_error_class
  end

  it 'records all verify calls and returns predefined answers' do
    subject.stub_receipt!
    subject.verify(package, product_id, token)
      .valid?.must_be_true

    subject.stub_failure!
    subject.verify(package, product_id, token)
      .code.wont_be_nil

    recoreded = subject.recorder.to_a

    recoreded.size.must_equal 2
    recoreded.first.package.must_equal package
    recoreded.first.product_id.must_equal product_id
    recoreded.first.token.must_equal token
  end

  it 'fetches receipts with default attributes' do
    got = subject.fetch_receipt
    got.must_be_instance_of CandyCheck::PlayStore::Receipt
    got.valid?.must_be_true
  end

  it 'fetches receipts with merged attributes' do
    got = subject.fetch_receipt('developerPayload' => 'merged')
    got.must_be_instance_of CandyCheck::PlayStore::Receipt
    got.developer_payload.must_equal 'merged'
  end

  it 'fetches verficication_failure with default code' do
    subject.fetch_verification_failure.code.must_equal 401
  end

  it 'fetches verficication_failure with custom code' do
    subject.fetch_verification_failure(100).code.must_equal 100
  end

  it 'stub_receipt! w/o arguments' do
    subject.stub_receipt!
    subject.answers.size.must_equal 1
    subject.answers.first.valid?.must_be_true
  end

  it 'stub_receipt! from a hash' do
    subject.stub_receipt!('developerPayload' => 'merged')
    subject.answers.size.must_equal 1
    subject.answers.first.developer_payload.must_equal 'merged'
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
    subject.stub_failure!(100)
    subject.answers.size.must_equal 1
    subject.answers.first.code.must_equal 100
  end

  it 'stub_failure! from a code' do
    obj = Object.new
    subject.stub_failure!(obj)
    subject.answers.size.must_equal 1
    subject.answers.first.must_be_same_as obj
  end
end
