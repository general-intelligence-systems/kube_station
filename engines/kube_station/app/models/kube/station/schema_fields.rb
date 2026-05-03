# frozen_string_literal: true

module Kube
  module Station
    class SchemaFields
      def self.call(schema, data)
        new(schema, data).call
      end

      def initialize(schema, data)
        @schema = schema
        @data = data || {}
      end

      def call
        properties = @schema.value["properties"] || {}
        required = @schema.value["required"] || []
        properties.map do |name, prop|
          build_field(name, prop, value_for(@data, name), "resource[#{name}]", required.include?(name))
        end
      end

      private

      def value_for(data, name)
        data[name.to_sym] || data[name]
      end

      def build_field(name, prop_schema, value, path, required, depth: 0)
        prop_schema = resolve_ref(prop_schema)
        type = prop_schema["type"]
        enum_values = prop_schema["enum"]
        description = prop_schema["description"]
        format = prop_schema["format"]

        if enum_values
          choices = enum_values.map { |v| [v, v] }
          { method: :select, attr: name.to_sym, choices: choices,
            options: { selected: value.to_s, name: path, label: name, required: required, hint: description } }
        elsif type == "boolean"
          { method: :check_box, attr: name.to_sym,
            options: { checked: !!value, name: path, label: name, kind: :toggle, hint: description } }
        elsif type == "integer" || type == "number" || format&.start_with?("int")
          { method: :number_field, attr: name.to_sym,
            options: { value: value, name: path, label: name, required: required, hint: description } }
        elsif type == "string" && format == "date-time"
          { method: :datetime_local_field, attr: name.to_sym,
            options: { value: value, name: path, label: name, required: required, hint: description } }
        elsif type == "string"
          { method: :text_field, attr: name.to_sym,
            options: { value: value.to_s, name: path, label: name, required: required, hint: description } }
        elsif type == "array"
          build_array_field(name, prop_schema, value, path, required, description, depth)
        elsif type == "object" && prop_schema["additionalProperties"]
          { type: :map, attr: name.to_sym, label: name, hint: description, path: path,
            values: (value.is_a?(Hash) ? value.to_a : []) }
        elsif type == "object" || prop_schema["properties"]
          build_object_field(name, prop_schema, value, path, required, description, depth)
        else
          { method: :text_field, attr: name.to_sym,
            options: { value: value.to_s, name: path, label: name, required: required, hint: description } }
        end
      end

      def build_object_field(name, prop_schema, value, path, required, description, depth)
        props = prop_schema["properties"] || {}
        req = prop_schema["required"] || []
        value = value || {}
        {
          type: :object, attr: name.to_sym, label: name, hint: description, open: depth < 1,
          fields: props.map do |pname, ps|
            build_field(pname, ps, value_for(value, pname), "#{path}[#{pname}]", req.include?(pname), depth: depth + 1)
          end
        }
      end

      def build_array_field(name, prop_schema, value, path, required, description, depth)
        items_schema = resolve_ref(prop_schema["items"] || {})
        items_type = items_schema["type"]
        {
          type: :array, attr: name.to_sym, label: name, required: required, hint: description,
          path: path, items_type: items_type, items_schema: items_schema, values: Array(value)
        }
      end

      def resolve_ref(prop_schema)
        if prop_schema["$ref"]
          @schema.ref(prop_schema["$ref"]).value
        else
          prop_schema
        end
      end
    end
  end
end
