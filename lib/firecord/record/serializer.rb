module Firecord
  module Record
    class Serializer
      def initialize(value, type)
        @value = value
        @type = type
      end

      def value
        @value.nil? ? @value : send(@type)
      end

      private

      %w(string datetime).each do |type|
        define_method(type) do
          @value.to_s
        end
      end

      def private_key
        @value
      end

      def integer
        @value.respond_to?(:to_i) ? @value.to_i : nil
      end

      def float
        @value.respond_to?(:to_f) ? @value.to_f : nil
      end
    end
  end
end
