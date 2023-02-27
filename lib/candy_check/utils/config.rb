module CandyCheck
  module Utils
    # Very basic base implementation to store and validate a configuration
    class Config
      # Initializes a new configuration from a hash
      # @param attributes [Hash]
      def initialize(attributes)
        if attributes.is_a?(Hash)
          attributes.each do |k, v|
            instance_variable_set "@#{k}", v
          end
        end
        validate!
      end

      protected

      # Hook to check for validation error in the sub classes
      # should raise an error if not passed
      def validate!
        # pass
      end

      # Check for the presence of an attribute
      # @param name [String]
      # @raise [ArgumentError] if attribute is missing
      def validates_presence(name)
        return if send(name)

        raise ArgumentError, "Configuration field #{name} is missing"
      end

      # Checks for the inclusion of an attribute
      # @param name [String]
      # @param values [Array] of possible values
      def validates_inclusion(name, *values)
        return if values.include?(send(name))

        raise ArgumentError, "Configuration field #{name} should be "\
                            "one of: #{values.join(', ')}"
      end
    end
  end
end
