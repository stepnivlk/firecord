module Firecord
  module Model
    def self.extended(model)
      model.instance_variable_set(:@fields, [])
    end

    def field(name, type)
      @fields << OpenStruct.new({name: name, type: type})
    end

    def fields
      @fields
    end
  end
end
