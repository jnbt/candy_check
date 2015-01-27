module CandyCheck
  module TestHelper
    # Holds and returns predefined responses
    class AnswerList
      include Enumerable
      # Error raised if no answer if left to be fetched
      class MissingAnswerError < RuntimeError; end

      # @return [Array] list of available results
      attr_reader :answers

      # If no answer is left, the +failure_message+ will be raised an error
      # @param failure_message [String]
      def initialize(failure_message)
        @answers         = []
        @failure_message = failure_message
      end

      # Return the next predefined result
      # @raise [MissingAnswerError] if no answer is left
      # @return [Object]
      def fetch
        guard!
        answers.shift
      end

      # Adds a predefined result
      # @param object [Object]
      def <<(object)
        answers << object
      end

      # @return [Fixnum] The current amount of available results
      def size
        answers.size
      end

      # Iterates over all available results
      # @yield [obj] Called for each result
      # @return [Array] available results
      def each(&block)
        answers.each(&block)
      end

      private

      def guard!
        answers.empty? && fail(MissingAnswerError, @failure_message)
      end
    end
  end
end
