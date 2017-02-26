module Firecord
  module Record
    def self.included(model)
      model.extend(Model)
      super
    end

    alias_method :model, :class

    def initialize(params = {})
      fields.each do |field|
        self.class.class_eval{attr_accessor field.name}
        value = params[field.name] || nil
        instance_variable_set("@#{field.name}", value)
      end
    end

    def save
      repository.post(self)
    end

    def inspect
      attrs = fields.map do |field|
        "#{field.name}=#{send(field.name) || 'nil'}"
      end

      "#<#{model.name} #{attrs.join(' ')}>"
    end

    def fields
      model.fields
    end

    def repository
      model.repository
    end
  end
end
