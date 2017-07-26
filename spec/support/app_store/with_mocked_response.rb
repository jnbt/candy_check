module AppStore
  module WithMockedResponse
    DummyClient = Struct.new(:response) do
      attr_reader :receipt_data, :secret

      def verify(receipt_data, secret)
        @receipt_data = receipt_data
        @secret = secret
        response
      end
    end

    def with_mocked_response(response)
      recorded = []
      dummy    = DummyClient.new(response)
      stub     = proc do |*args|
        recorded << args
        dummy
      end
      CandyCheck::AppStore::Client.stub :new, stub do
        yield dummy, recorded
      end
    end
  end
end
