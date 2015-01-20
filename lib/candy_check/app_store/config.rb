module CandyCheck
  module AppStore
    # Configure the verifier
    class Config < Utils::Config
      # @return [Symbol] the used environment
      attr_reader :environment

      # Initializes a new configuration from a hash
      # @param attributes [Hash]
      # @example
      #   Config.new(
      #     environment: :production # or :sandbox
      #   )
      def initialize(attributes)
        super
      end

      # @return [Boolean] if it is production environment
      def production?
        environment == :production
      end

      private

      def validate!
        validates_inclusion(:environment, :production, :sandbox)
      end
    end
  end
end
