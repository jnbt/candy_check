module CandyCheck
  module Utils
    # Very basic base implementation to store and validate a configuration
    class Config
      # Initializes a new configuration from a [Hash]
      # @param attributes [Hash]
      def initialize(attributes)
        attributes.each do |k, v|
          instance_variable_set "@#{k}", v
        end if attributes.is_a? Hash
        validate!
      end

      protected

      def validate!
        # pass
      end

      def validates_presence(name)
        return if send(name)
        fail ArgumentError, "Configuration field #{name} is missing"
      end
    end
  end
end
