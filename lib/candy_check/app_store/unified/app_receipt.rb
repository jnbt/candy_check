module CandyCheck
  module AppStore
    module Unified
      # Describes a successful response from the AppStore verification server
      # which present in ios 7 style app unified receipt format
      class AppReceipt
        include Utils::AttributeReader

        # @return [Hash] the raw attributes returned from the server
        attr_reader :attributes

        # Initializes a new instance which bases on a JSON result
        # from Apple's verification server
        # @param attributes [Hash]
        def initialize(attributes)
          @attributes = attributes
        end

        # The app's bundle identifier
        # @return [String]
        def bundle_id
          read('bundle_id')
        end

        # The app version number
        # @return [String]
        def application_version
          read('application_version')
        end

        # The array of in-app purchase receipts
        # @return [Array<CandyCheck::AppStore::Unified::InAppReceipt>]
        def in_app_receipts
          read('in_app').map { |raw_receipt| InAppReceipt.new(raw_receipt) }
        end

        # The version of the app that was originally purchased
        # @return [String]
        def original_application_version
          read('original_application_version')
        end

        # The date when the app receipt was created
        # @return [DateTime]
        def creation_date
          read_datetime_from_string('receipt_creation_date')
        end

        # The date that the app receipt expires.
        # This key is present only for apps purchased through
        # the Volume Purchase Program
        # @return [DateTime, nil]
        def expiration_date
          read_datetime_from_string('expiration_date')
        end
      end
    end
  end
end
