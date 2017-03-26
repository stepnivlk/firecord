require '../lib/firecord'

Firecord.configure do |config|
  config.credentials_file = '../../credentials.json'
end

class Address
  include Firecord::Record

  root_key 'addresses'

  field :name, :string
  field :location, :string
  field :door_number, :integer
  field :timestamps
end
