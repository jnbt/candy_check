module CandyCheck
  module AppStore
    module Unified
      # Verifies a grand unified receipt againts a verification server
      class Verification < CandyCheck::AppStore::Verification
        # Performs the verification against the remote server
        # @return [Unified::VerifiedResponse] if successful
        # @return [VerificationFailure] otherwise
        def call!
          verify!
          if valid?
            Unified::VerifiedResponse.new(@response)
          else
            VerificationFailure.fetch(@response['status'])
          end
        end

        private

        def valid?
          @response && @response['status'] == STATUS_OK && @response['receipt']
        end
      end
    end
  end
end
