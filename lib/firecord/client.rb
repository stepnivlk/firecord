require 'httparty'

module Firecord
  class Client
    include HTTParty

    def initialize(options = {})
      @credentials = Credentials.new
      self.class.base_uri "https://#{@credentials.project_id}.firebaseio.com/"
      @options = {
        headers: {
          "Authorization" => "Bearer #{@credentials.generate_access_token}",
          "Content-Type" => "application/json",
          "User-Agent" => 'X-JOINME-CLIENT'
        }
      }
    end

    def get(resource)
      self.class.get("/#{resource}.json", @options)
    end
  end
end
