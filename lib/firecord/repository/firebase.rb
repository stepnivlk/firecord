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
          .as { |response| Response.new(response).sanitize }
          .map { |id, data| data.merge(id: id) }
      end

      def get(id)
        self
          .class.get("/#{@root}/#{id}.json", options)
          .as { |response| Response.new(response, id: id).sanitize(false) }
      end

      def post(record)
        self
          .class.post("/#{@root}.json", payload(record))
          .as { |response| Response.new(response).sanitize }
      end

      def patch(record)
        self
          .class.patch("/#{@root}/#{record.id}.json", payload(record))
          .as { |response| Response.new(response).sanitize }
      end

      def delete(id)
        self
          .class.delete("/#{@root}/#{id}.json", options)
          .as { |response| response ? false : true }
      end

      private

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
