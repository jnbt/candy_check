require 'spec_helper'

describe CandyCheck::CLI::Commands::Version do
  include WithCommand
  subject { CandyCheck::CLI::Commands::Version }

  it 'prints the gem\'s version' do
    run_command!
    _(out.lines).must_equal [CandyCheck::VERSION]
  end
end
