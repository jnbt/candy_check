module CandyCheck
  module PlayStore
    module AndroidPublisherService
      def android_publisher_service
        @android_publisher_service ||= Google::Apis::AndroidpublisherV3::AndroidPublisherService.new
      end
    end
  end
end
