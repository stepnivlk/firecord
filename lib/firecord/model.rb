module Firecord
  module Model
    def self.extended(model)
      private_key = OpenStruct.new({name: :id, type: :private_key})
      model.instance_variable_set(:@fields, [private_key])
    end

    def field(name, type = nil)
      return timestamps if name == :timestamps

      @fields << OpenStruct.new({name: name, type: type})
    end

    def timestamps
      %i(created_at updated_at).each do |stamp|
        @fields << OpenStruct.new({name: stamp, type: stamp})
      end
    end

    def fields
      @fields
    end

    def all
      repository
        .get_all
        .map { |record| new(record) }
    end

    def find(id)
      new(repository.get(id))
    end

    def root_key(root_name)
      @root = root_name
    end

    def root
      @root || name.downcase
    end

    def repository
      @repository ||= Repository::Firebase.new(root)
    end
  end
end
