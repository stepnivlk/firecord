module Firecord
  module Repository
    class Response
      def initialize(response, default = {})
        @response = response
        @default = default
      end

      def sanitize(expand_error = true)
        @response ? symbolize_keys : invalid_record(expand_error)
      end

      private

      def symbolize_keys
        @response.inject(@default) do |result, (key, value)|
          result[key.to_sym] = value
          result
        end
      end

      def invalid_record(expand_error)
        expand_error ? {nil => {error: 'invalid response'}} : nil
      end
    end
  end
end
