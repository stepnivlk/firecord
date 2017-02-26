module Firecord
  module Configuration
    CREDENTIALS_FILE = './credentials.json'.freeze

    VALID_ACCESSORS = [:credentials_file].freeze

    attr_accessor(*VALID_ACCESSORS)

    def configure
      yield self
    end

    def options
      VALID_ACCESSORS.inject({}) do |accessor, key|
        accessor.merge!(key => send(key))
      end
    end

    def self.extended(mod)
      mod.set_defaults
    end

    def set_defaults
      self.credentials_file = CREDENTIALS_FILE
    end
  end
end
