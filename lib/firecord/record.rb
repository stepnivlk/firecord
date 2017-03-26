module Firecord
  module Record
    def self.included(model)
      model.extend(Model)
      super
    end

    alias model class

    def initialize(params = {})
      fields.each do |field|
        initialize_accessor(field, params)
      end
    end

    def save
      return _create if new?

      _update
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
        value = get_value(field.name)
        formatted = value.is_a?(String) ? "\"#{value}\"" : value

        "#{field.name}=#{formatted || 'nil'}"
      }

      "#<#{model.name} #{attrs.join(' ')}>"
    end

    def new?
      persistence_state == :transient
    end

    def persist
      @persistence_state = :persisted

      self
    end

    def method_missing(method, *args, &block)
      return super unless available_names.include?(method)

      return set_value(method, args[0]) if method.to_s.end_with?('=')
      get_value(method)
    end

    def respond_to_missing?(method, include_private = false)
      available_names.include?(method) || super
    end

    def fields
      model.fields
    end

    private

    def set_value(name, value, type = nil)
      type ||= field_for(name).type
      sanitizer = Serializer.new(value, type)

      send("_#{name}", sanitizer.value)
    end

    def get_value(name)
      value = send("_#{name}")

      return value if value.nil?

      Deserializer.new(value, field_for(name).type).value
    end

    def available_names
      fields.map(&:name) + fields.map { |field| :"#{field.name}=" }
    end

    def _create
      tap do |record|
        record.created_at = DateTime.now
        record.id = repository.post(persist)[:name]
      end
    end

    def _update
      tap do |record|
        record.updated_at = DateTime.now
        repository.patch(record)
      end
    end

    def field_for(name)
      sanitized_name = name.to_s.end_with?('=') ? :"#{name[0..-2]}" : name
      fields.find { |field| field.name == sanitized_name }
    end

    def repository
      model.repository
    end

    def persistence_state
      @persistence_state ||= :transient
    end

    def initialize_accessor(field, params)
      name = field.name

      restrict_accessor(name)

      value = params[name] || nil
      set_value("#{name}=", value, field.type) if value
    end

    def restrict_accessor(name)
      self.class.class_eval do
        attr_accessor("_#{name}")
      end

      self.class.instance_eval do
        private(:"_#{name}")
        private(:"_#{name}=")
      end
    end
  end
end
