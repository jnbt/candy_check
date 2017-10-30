require 'date'

module CandyCheck
  module Utils
    # @private
    module AttributeReader
      protected

      def read(field)
        attributes[field]
      end

      def has?(field)
        attributes.key?(field)
      end

      def read_integer(field)
        (val = read(field)) && val.to_i
      end

      # @return [bool] if value is either 'true' or 'false'
      # @return [nil] if value is not 'true'/'false'
      def read_bool(field)
        val = read(field).to_s
        return nil unless %w(false true).include?(val)
        val == 'true'
      end

      def read_datetime_from_string(field)
        (val = read(field)) && DateTime.parse(val)
      end

      def read_datetime_from_millis(field)
        (val = read_integer(field)) && Time.at(val / 1000).utc.to_datetime
      end
    end
  end
end
