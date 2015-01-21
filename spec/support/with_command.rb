module WithCommand
  def out
    @out ||= OutRecorder.new
  end

  def run_command!
    CandyCheck::CLI::Out.stub :new, out do
      subject.run(*arguments)
    end
  end

  def arguments
    []
  end

  class OutRecorder
    def lines
      @lines ||= []
    end

    def print(text = '')
      lines << text
    end

    def pretty(object)
      lines << object
    end

    def must_be(*expected)
      lines.must_equal expected
    end
  end
end
