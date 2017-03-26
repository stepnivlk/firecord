module Firecord
  module Model
    def self.extended(model)
      model.instance_variable_set(:@fields, [])
      model.fields << OpenStruct.new(name: :id, type: :private_key)
    end

    def field(name, type = nil)
      return timestamps if name == :timestamps

      @fields << OpenStruct.new(name: name, type: type)
    end

    def timestamps
      %i(created_at updated_at).each do |stamp|
        @fields << OpenStruct.new(name: stamp, type: :datetime)
      end
    end

    def all
      repository
        .all
        .reject { |response| response.keys.include?(:error) }
        .map { |response| new(response).persist }
    end

    def find(id)
      response = repository.get(id)
      response.nil? ? nil : new(response).persist
    end

    def where(query)
      validate_query!(query)

      all.select do |record|
        result = query.map { |name, value| record.send(name) == value }.uniq

        result.size == 1 && result[0] == true ? true : false
      end
    end

    def root_key(root_name)
      @root = root_name
    end

    def fields
      @fields
    end

    def root
      @root || name.downcase
    end

    def repository
      @repository ||= Repository::Firebase.new(root)
    end

    def validate_query!(query)
      result = query.keys - fields.map(&:name)
      raise InvalidQuery, 'Your query contains invalid key(s)' \
        unless result.empty?
    end
  end
end
