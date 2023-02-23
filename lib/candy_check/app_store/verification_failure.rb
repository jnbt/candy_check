module CandyCheck
  module AppStore
    # Represents a failing call against the verification server
    class VerificationFailure
      # @return [Integer] the code of the failure
      attr_reader :code

      # @return [String] the message of the failure
      attr_reader :message

      # Initializes a new instance which bases on a JSON result
      # from Apple servers
      # @param code [Integer]
      # @param message [String]
      def initialize(code, message)
        @code = code
        @message = message
      end

      class << self
        # Gets a known failure or build an unknown failure
        # without description
        # @param code [Integer]
        # @return [VerificationFailure]
        def fetch(code)
          known.fetch(code) do
            fallback(code)
          end
        end

        private

        def fallback(code)
          new(code || -1, 'Unknown error')
        end

        def known
          @known ||= {}
        end

        def add(code, name)
          known[code] = new(code, name)
        end

        def freeze!
          known.freeze
        end
      end

      add 21_000, 'The request to the App Store was not made using' \
                  ' the HTTP POST request method.'
      add 21_001, 'This status code is no longer sent by the App Store.'
      add 21_002, 'The data in the receipt-data property was malformed' \
                  ' or the service experienced a temporary issue. Try again.'
      add 21_003, 'The receipt could not be authenticated.'
      add 21_004, 'The shared secret you provided does not match the shared' \
                  ' secret on file for your account.'
      add 21_005, 'The receipt server was temporarily unable to provide' \
                  ' the receipt. Try again.'
      add 21_006, 'This receipt is valid but the subscription has expired.' \
                  ' When this status code is returned to your server, the' \
                  ' receipt data is also decoded and returned as part of' \
                  ' the response. Only returned for iOS 6-style transaction' \
                  ' receipts for auto-renewable subscriptions.'
      add 21_007, 'This receipt is from the test environment, but it was' \
                  ' sent to the production environment for verification.'
      add 21_008, 'This receipt is from the production environment, but it' \
                  ' was sent to the test environment for verification.'
      add 21_009, 'Internal data access error. Try again later.'
      add 21_010, 'The user account cannot be found or has been deleted.'
      freeze!
    end
  end
end
