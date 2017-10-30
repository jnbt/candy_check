require 'spec_helper'

describe CandyCheck::CLI::Commands::Version do
  include WithCommand
  subject { CandyCheck::CLI::Commands::Version }

  it 'prints the gem\'s version' do
    run_command!
    out.must_be CandyCheck::VERSION
  end
end
