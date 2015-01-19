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

      def read_datetime_from_string(field)
        (val = read(field)) && DateTime.parse(val)
      end

      def read_datetime_from_millis(field)
        (val = read_integer(field)) && Time.at(val / 1000).utc.to_datetime
      end
    end
  end
end
