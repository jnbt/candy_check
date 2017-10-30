require 'pp'

module CandyCheck
  module CLI
    # A wrapper to output text information to any kind of buffer
    # @example
    #   out = Out.new(std_buffer)
    #   out.print('something') # => appends 'something' to std_buffer
    class Out
      # @return [Object] buffer used as default outlet
      attr_reader :out

      # Bind a new out instance to two buffers
      # @param out [Object] STDOUT is default
      def initialize(out = $stdout)
        @out = out
      end

      # Prints to +out+
      # @param text [String]
      def print(text = '')
        out.puts text
      end

      # Pretty print an object to +out+
      # @param object [Object]
      def pretty(object)
        PP.pp(object, out)
      end
    end
  end
end
