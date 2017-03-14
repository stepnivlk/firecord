module Firecord
  module Record
    def self.included(model)
      model.extend(Model)
      super
    end

    alias model class

    def initialize(params = {})
      fields.each do |field|
        name = field.name

        self.class.class_eval do attr_accessor(name) end
        value = params[name] || nil
        instance_variable_set("@#{name}", value)
      end
    end

    def save
      timestamp = DateTime.now.to_s

      if new?
        return tap do |record|
          record.created_at = timestamp
          record.id = repository.post(persist)[:name]
        end
      end

      tap do |record|
        record.updated_at = timestamp
        repository.patch(record)
      end
    end

    def update(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end

      tap { |record| repository.patch(record) }
    end

    def delete
      repository.delete(id)
    end

    def inspect
      attrs = fields.map { |field|
        "#{field.name}=#{send(field.name) || 'nil'}"
      }

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
