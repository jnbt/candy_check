module CandyCheck
  module TestHelper
    module AppStore
      # A substitute for the actual {CandyCheck::AppStore::Verifier} class.
      # @example Usage with MiniTest
      #   require 'candy_check/test_helper'
      #
      #   fake_verifier = CandyCheck::TestHelper::AppStore::FakeVerifier.new
      #   fake_verifier.stub_receipt! # first +verify+ call returns a receipt
      #   fake_verifier.stub_failure! # second +verify+ call returns a failure
      #
      #   CandyCheck::AppStore::Verifier.stub :new, fake_verifier do
      #     # your actual test code goes here
      #   end
      #
      #   # Now you can validate the received calls
      #   fake_verifier.assert_calls!(
      #     ['some-receipt'], ['another-receipt', 'with-secret']
      #   )
      class FakeVerifier
        # @return [CallRecorder] to store all +verify+ calls
        attr_reader :recorder
        # @return [AnswerList] to stub responses for +verify+ calls
        attr_reader :answers
        # @return [CandyCheck::AppStore::Config] the given config
        attr_reader :config

        # Initializes a new FakeVerifier which returns mocked
        # verification results
        # @param config [CandyCheck::AppStore::Config] to hold
        def initialize(config = nil)
          @config   = config
          @recorder = CallRecorder.new(:receipt_data, :secret)
          @answers  = AnswerList.new('No answer stubbed for FakeVerifier. ' \
                                     'Use stub_receipt! or stub_failure!')
        end

        # Add one successful result to the +verify+ calls responses
        # @overload stub_receipt()
        #   Build with default values
        # @overload stub_receipt(receipt)
        #   Merged with default values to build a Receipt
        #   @param receipt [Hash] to be used as attributes
        # @overload stub_receipt(receipt)
        #   Any other object to use as response
        #   @param receipt [Object] to use as response
        # @return [FakeVerifier] this object
        def stub_receipt!(receipt = nil)
          answers << case receipt
                     when nil
                       fetch_receipt
                     when Hash
                       fetch_receipt(receipt)
                     else
                       receipt
                     end
          self
        end

        # Add one failure result to the +verify+ calls responses
        # @overload stub_failure
        #   Use default verification failure
        # @overload stub_failure(failure)
        #   Fetch by using the failure code
        #   @param failure [Fixnum] to be used as failure code
        # @overload stub_failure(failure)
        #   Any other object to use as response
        #   @param failure [Object] to use as response
        # @return [FakeVerifier] this object
        def stub_failure!(failure = nil)
          answers << case failure
                     when nil
                       fetch_verification_failure
                     when Fixnum
                       fetch_verification_failure(failure)
                     else
                       failure
                     end
          self
        end

        # Records the arguments and returns predefined result from the
        # answer list.
        # Calls a verification for the given input
        # @param receipt_data [String] the raw data to be verified
        # @param secret [String] the optional shared secret
        # @return [CandyCheck::AppStore::Receipt,
        #          CandyCheck::AppStore::VerificationFailure] the result
        # @raise [AnswerList::MissingAnswerError] if not enough answers are set
        def verify(receipt_data, secret = nil)
          recorder << [receipt_data, secret]
          answers.fetch
        end

        # Validates are recorded calls against the given arguments.
        # Each call will be matches against an array of arguments.
        # @example How to use
        #   verifier.assert_calls!(['data'], ['more-data', 'secret'])
        #   # First call must be done with 'data' as receipt_data
        #   # Second call must be done with 'data' as receipt_data, and
        #   # 'secret' as secret
        # @param call_arguments [Array<Array>] array call arguments
        def assert_calls!(*call_arguments)
          recorder.assert_calls(*call_arguments)
        end

        # Builds a new receipt merging with default attributes
        # @param overrides [Hash] to be merged into default attributes
        # @return [CandyCheck::AppStore::Receipt]
        def fetch_receipt(overrides = {})
          CandyCheck::AppStore::Receipt.new(build_receipt_attributes(overrides))
        end

        # Fetches a +VerificationFailure+ from the code
        # @param code [Fixnum] to be looked up
        # @return [CandyCheck::AppStore::VerificationFailure]
        def fetch_verification_failure(code = 21_000)
          CandyCheck::AppStore::VerificationFailure.fetch(code)
        end

        private

        def build_receipt_attributes(overrides)
          build_valid_receipt_attributes(Time.now).merge(overrides)
        end

        def build_valid_receipt_attributes(now)
          build_receipt_transaction_attributes.merge(
            'original_transaction_id' => 'original-transaction-id',
            'bvrs'                    => '1.0',
            'bid'                     => 'fake.app',
            'product_id'              => 'product-id',
            'item_id'                 => 'item-id',
            'quantity'                => 1,
            'purchase_date'           => now.to_s,
            'original_purchase_date'  => now.to_s
          )
        end

        def build_receipt_transaction_attributes
          @next_transaction_id ||= 0
          @next_transaction_id += 1
          {
            'transaction_id' => "transaction-#{@next_transaction_id}"
          }
        end
      end
    end
  end
end
