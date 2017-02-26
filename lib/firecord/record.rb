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
      if new?
        return self.tap do |record|
          record.id = repository.post(persist)[:name]
        end
      end

      self.tap { |record| repository.patch(record) }
    end

    def update(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end

      self.tap { |record| repository.patch(record) }
    end

    def delete
      repository.delete(id)
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

    def new?
      persistence_state == :transient
    end

    def persist
      @persistence_state = :persisted

      self
    end

    def persistence_state
      @persistence_state ||= :transient
    end
  end
end
