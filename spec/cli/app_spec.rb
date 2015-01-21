require 'spec_helper'

describe CandyCheck::CLI::App do
  subject { CandyCheck::CLI::App.new }

  it 'supports the version command' do
    stub_command(CandyCheck::CLI::Commands::Version) do
      subject.version.must_equal :stubbed
      @arguments.must_be_empty
    end
  end

  it 'supports the app_store command' do
    stub_command(CandyCheck::CLI::Commands::AppStore) do
      subject.app_store('receipt').must_equal :stubbed
      @arguments.must_equal ['receipt', {}]
    end
  end

  it 'supports the play_store command' do
    stub_command(CandyCheck::CLI::Commands::PlayStore) do
      subject.play_store('package', 'id', 'token').must_equal :stubbed
      @arguments.must_equal ['package', 'id', 'token', {}]
    end
  end

  private

  def stub_command(target)
    stub = proc do |*args|
      @arguments = args
      :stubbed
    end
    target.stub :run, stub do
      yield
    end
  end
end
