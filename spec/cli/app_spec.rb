require 'spec_helper'

describe CandyCheck::CLI::App do
  subject { CandyCheck::CLI::App.new }

  it 'supports the version command' do
    stub_command(CandyCheck::CLI::Commands::Version) do
      _(subject.version).must_equal :stubbed
      _(@arguments).must_be_empty
    end
  end

  it 'supports the app_store command' do
    stub_command(CandyCheck::CLI::Commands::AppStore) do
      _(subject.app_store('receipt')).must_equal :stubbed
      _(@arguments).must_equal ['receipt', {}]
    end
  end

  it 'supports the play_store command' do
    stub_command(CandyCheck::CLI::Commands::PlayStore) do
      _(subject.play_store('package', 'id', 'token')).must_equal :stubbed
      _(@arguments).must_equal ['package', 'id', 'token', {}]
    end
  end

  it 'returns true when call .exit_on_failure?' do
    _(CandyCheck::CLI::App.exit_on_failure?).must_equal true
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
