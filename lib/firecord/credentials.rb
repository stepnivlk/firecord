require 'jwt'

module Firecord
  class Credentials
    def initialize
      @credentials = JSON.parse(File.read('./credentials.json'))
      @private_key = OpenSSL::PKey::RSA.new @credentials['private_key']
    end

    def project_id
      @credentials['project_id']
    end

    def generate_jwt_assertion
      now_seconds = Time.now.to_i
      payload = {
        iss: @credentials['client_email'],
        aud: @credentials['token_uri'],
        iat: now_seconds,
        exp: now_seconds + (60 * 60),
        scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/firebase.database'
      }
      JWT.encode payload, @private_key, 'RS256'
    end

    def generate_access_token
      uri = URI.parse(@credentials['token_uri'])
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.path)
      req['Cache-Control'] = 'no-store'
      req.set_form_data(
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: generate_jwt_assertion
      )

      resp = JSON.parse(https.request(req).body)
      resp['access_token']
    end
  end
end
