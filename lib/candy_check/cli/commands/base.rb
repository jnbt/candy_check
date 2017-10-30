module CandyCheck
  module CLI
    module Commands
      # Base for all commands providing simple support for running a single
      # command and printing to an {Out} instance
      class Base
        # Initialize a new command and prepare options for the run
        # @param options [Object]
        def initialize(options = nil)
          @options = options
        end

        # Run a single instance of a command
        # @param args [Array] arguments for the command
        # @return [Base] the command after the run
        def self.run(*args)
          new(*args).tap(&:run)
        end

        protected

        # @return [Object] configuration for the run
        attr_reader :options

        def out
          @out ||= Out.new
        end
      end
    end
  end
end
