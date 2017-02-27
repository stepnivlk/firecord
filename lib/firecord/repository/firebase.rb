require 'httparty'

module Firecord
  module Repository
    class Firebase
      include HTTParty

      def initialize(root)
        @credentials = Credentials.new
        @root = root
        self.class.base_uri "https://#{@credentials.project_id}.firebaseio.com/"
      end

      def all
        self
          .class.get("/#{@root}.json", options)
          .map { |id, data| data.merge(id: id) }
          .map { |record| symbolize_keys(record) }
      end

      def get(id)
        self
          .class.get("/#{@root}/#{id}.json", options)
          .as { |record| sanitize(record, id: id) }
      end

      def post(record)
        self
          .class.post("/#{@root}.json", payload(record))
          .as { |response| symbolize_keys(response) }
      end

      def patch(record)
        self
          .class.patch("/#{@root}/#{record.id}.json", payload(record))
          .as { |response| sanitize(response) }
      end

      def delete(id)
        self
          .class.delete("/#{@root}/#{id}.json", options)
          .as { |response| response.nil? ? true : false }
      end

      private

      def sanitize(record, default = {})
        record.nil? ? nil : symbolize_keys(record, default)
      end

      def symbolize_keys(record, default = {})
        record.inject(default) { |h, (k, v)| h[k.to_sym] = v; h }
      end

      def payload(record)
        options.dup.tap do |data|
          data[:body] = body(record).to_json
        end
      end

      def body(record)
        record.fields.each_with_object({}) do |field, data|
          next if field.type == :private_key

          data[field.name] = record.send(field.name)
        end
      end

      def options
        {
          headers: {
            'Authorization' => "Bearer #{@credentials.generate_access_token}",
            'Content-Type' => 'application/json',
            'User-Agent' => 'X-FIREBASE-CLIENT'
          }
        }
      end
    end
  end
end
