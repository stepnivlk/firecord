module Firecord
  module Record
    class Deserializer
      def initialize(value, type)
        @value = value
        @type = type
      end

      def value
        send(@type)
      end

      private

      %w(string integer float private_key).each do |type|
        define_method(type) do
          @value
        end
      end

      def datetime
        DateTime.parse(@value)
      end
    end
  end
end
