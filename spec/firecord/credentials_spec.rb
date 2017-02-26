require "spec_helper"

describe Firecord::Credentials do
  context 'valid credentials.json given' do
    let(:fixtures_path) {
      File.join(File.dirname(__dir__), 'fixtures', 'fake_credentials.json')
    }
    let(:credentials) { described_class.new(fixtures_path) }
    let(:credentials_file) { JSON.parse(File.read(fixtures_path)) }
    let(:decoded) { JWT.decode(credentials.generate_jwt_assertion, nil, false) }

    it 'Initializes itself properly' do
      expect(credentials.project_id).to eq('addrssr-8612c')
    end

    it 'Encodes credentials data to JWT' do
      expect(decoded).to be_a(Array)
      expect(decoded.size).to eq(2)
      expect(decoded[0]).to include(
        'iss' => credentials_file['client_email'],
        'aud' => credentials_file['token_uri'],
        'scope' => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/firebase.database'
      )
      expect(decoded[0]['iat']).to_not be_nil
      expect(decoded[0]['exp']).to_not be_nil

      expect(decoded[1]).to include(
        'typ' => 'JWT',
        'alg' => 'RS256'
      )
    end

    it 'Contacts remote API and generates access token' do
      VCR.use_cassette('credentials_access_token') do
        expect(credentials.generate_access_token).to_not be_nil
      end
    end
  end

  context 'invalid credentials.json given' do
    it 'raises an exception' do
      expect { described_class.new('invalid_path') }.to raise_error(Errno::ENOENT)
    end
  end
end
