module CandyCheck
  module PlayStore
    class Acknowledger
      def initialize(authorization:)
        @authorization = authorization
      end

      def acknowledge_product_purchase(package_name:, product_id:, token:)
        acknowledger = CandyCheck::PlayStore::ProductAcknowledgements::Acknowledgement.new(
          package_name: package_name,
          product_id: product_id,
          token: token,
          authorization: @authorization,
        )
        acknowledger.call!
      end
    end
  end
end
