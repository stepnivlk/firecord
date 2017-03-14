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
        @fields << OpenStruct.new(name: stamp, type: stamp)
      end
    end

    def all
      repository
        .all
        .reject { |response| response.keys.include?(:error) }
        .map { |response| new(response).persist }
    end

    def find(id)
      repository.get(id).tap do |response|
        response ? new(response).persist : nil
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

    private

    def repository
      @repository ||= Repository::Firebase.new(root)
    end
  end
end
