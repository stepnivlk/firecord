module Firecord
  module Record
    def self.included(model)
      model.extend(Model)
      super
    end

    alias_method :model, :class

    def inspect
      attrs = fields.map do |field|
        "#{field.name}=#{field.value == nil ? 'nil' : field.value}"
      end

      "#<#{model.name} #{attrs.join(' ')}>"
    end

    def fields
      model.fields
    end
  end
end
