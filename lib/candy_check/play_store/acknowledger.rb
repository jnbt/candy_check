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

      def acknowledge_subscription_purchase(package_name:, subscription_id:, token:)
        CandyCheck::PlayStore::SubscriptionAcknowledgements::Acknowledgement.new(
          package_name: package_name,
          subscription_id: subscription_id,
          token: token,
          authorization: @authorization,
        ).call!
      end
    end
  end
end
