module CandyCheck
  module TestHelper
    # Stores and validates calls
    class CallRecorder
      # Error raised if an expectation is not met
      class ExpectationError < RuntimeError; end
      include Enumerable

      # Builds a new +CallRecorder+ for the given arguments
      # @param parameters [Array] names of arguments
      def initialize(*parameters)
        @call_class = Struct.new(*parameters)
        @recorded   = []
      end

      # Records a call
      # @param args [Array] of arguments
      def <<(args)
        @recorded << build(args)
      end

      # Iterates over all recorded calls
      # @param block [Block]
      # @yield [obj] Call for each recorded call
      # @return [Array] recorded calls
      def each(&block)
        @recorded.each(&block)
      end

      # @return [Fixnum] The amount of recorded calls
      def size
        @recorded.size
      end

      # Assets that the recorded calls are matching a list of arguments
      # @param call_arguments [Array<Array>]
      # @raise [ExpectationError] if the expectations don't match
      def assert_calls(*call_arguments)
        assert_number_of_calls(call_arguments.size)
        assert_each do |rec, i|
          expected = build(call_arguments[i])
          assert rec == expected, "Expected call #{expected.inspect}, but " \
                                  "recorded call #{rec.inspect}"
        end
      end

      private

      def build(args)
        @call_class.new(*args)
      end

      def assert_number_of_calls(expected)
        assert size == expected, "Expected #{expected} call(s), " \
                                 "but recorded #{size} call(s)"
      end

      def assert_each(&block)
        each_with_index do |rec, i|
          block.call(rec, i)
        end
      end

      def assert(value, message)
        fail ExpectationError, message unless value
      end
    end
  end
end
