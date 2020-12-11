module CandyCheck
  module PlayStore
    module SubscriptionAcknowledgements
      class Response
        def initialize(result:, error_data:)
          @result = result
          @error_data = error_data
        end

        def acknowledged?
          !!result
        end

        def error
          return unless error_data

          { status_code: error_data.status_code, body: error_data.body }
        end

        attr_reader :result, :error_data
      end
    end
  end
end
