require "spec_helper"

describe CandyCheck::PlayStore::ProductAcknowledgements::Response do
  subject do
    CandyCheck::PlayStore::ProductAcknowledgements::Response.new(result: result, error_data: error_data)
  end

  describe '#acknowledged?' do
    context 'when result present' do
      let(:result) { '' }
      let(:error_data)  { nil }

      it 'returns true' do
        result = subject.acknowledged?

        result.must_be_true
      end
    end

    context 'when result is not present' do
      let(:result) { nil }
      let(:error_data)  { nil }

      it 'returns false' do
        result = subject.acknowledged?

        result.must_be_false
      end
    end
  end

  describe '#error' do
    context 'when error present' do
      let(:result) { nil }
      let(:error_data) do
        Module.new do
          def status_code
            400
          end
          def body
            'A String describing the issue'
          end
          module_function :status_code, :body
        end
      end

      it 'returns the expected data' do
        result = subject.error

        result[:status_code].must_equal(400)
        result[:body].must_equal('A String describing the issue')
      end
    end

    context 'when error is not present' do
      let(:result) { '' }
      let(:error_data)  { nil }

      it 'returns false' do
        result = subject.error

        result.must_be_nil
      end
    end
  end
end
