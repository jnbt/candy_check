module CandyCheck
  module CLI
    module Commands
      # Command to show the gem's version
      class Version < Base
        # Prints the current gem's version to the command line
        def run
          out.print CandyCheck::VERSION
        end
      end
    end
  end
end
