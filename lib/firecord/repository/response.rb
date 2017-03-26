module Firecord
  module Repository
    class Response
      def initialize(response, default = {})
        @response = response
        @default = default
      end

      def sanitize
        @response ? symbolize_keys : invalid_record
      end

      def sanitize_with_nil
        @response ? symbolize_keys : nil
      end

      private

      def symbolize_keys
        @response.each_with_object(@default) do |(key, value), result|
          result[key.to_sym] = value
          result
        end
      end

      def invalid_record
        { nil => { error: 'invalid response' } }
      end
    end
  end
end
