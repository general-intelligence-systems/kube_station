case field[:type]
when :object
  Accordion(open: field[:open]) { |a|
    a.title { text field[:label] }
    Segment(basic: true, style: "border-left: 2px solid #ddd; margin-left: 1em; padding-left: 1em;") {
      field[:fields].each do |f|
        Partial(partial: "schema_field", locals: { field: f })
      end
    }
  }

when :array
  path = field[:path]
  name = field[:label]
  items_type = field[:items_type]
  items_schema = field[:items_schema]

  DynamicList(label: name, type_hint: "#{items_type || 'object'}[]", required: field[:required], add_label: name.singularize) { |dl|
    dl.template {
      if items_type == "string" || items_type == "integer"
        HStack(spacing: 4, align: "center", data: { "schema-array-target": "item" }) {
          Input(placeholder: name.singularize, name: "#{path}[]",
                input_type: items_type == "integer" ? "number" : "text")
          Button(size: "mini", color: "red", icon: "x", type: :button, data: { action: "schema-array#remove" })
        }
      else
        obj_properties = items_schema["properties"] || {}
        Accordion(data: { "schema-array-target": "item" }) { |a|
          a.title {
            text name.singularize
            Button(size: "mini", color: "red", icon: "x", type: :button, data: { action: "schema-array#remove" })
          }
          obj_properties.each do |pname, _pschema|
            Wrapper(html_class: "field") {
              Label(size: :small) { text pname }
              Input(placeholder: pname, name: "#{path}[][#{pname}]")
            }
          end
        }
      end
    }

    if items_type == "string" || items_type == "integer"
      field[:values].each do |item|
        HStack(spacing: 4, align: "center", data: { "schema-array-target": "item" }) {
          Input(placeholder: name.singularize, value: item.to_s, name: "#{path}[]",
                input_type: items_type == "integer" ? "number" : "text")
          Button(size: "mini", color: "red", icon: "x", type: :button, data: { action: "schema-array#remove" })
        }
      end
    else
      obj_properties = items_schema["properties"] || {}
      field[:values].each_with_index do |item, i|
        Accordion(open: true, data: { "schema-array-target": "item" }) { |a|
          a.title {
            text "#{name.singularize} #{i + 1}"
            Button(size: "mini", color: "red", icon: "x", type: :button, data: { action: "schema-array#remove" })
          }
          obj_properties.each do |pname, _pschema|
            Wrapper(html_class: "field") {
              Label(size: :small) { text pname }
              Input(placeholder: pname, value: (item[pname.to_sym] || item[pname]).to_s, name: "#{path}[#{i}][#{pname}]")
            }
          end
        }
      end
    end
  }

when :map
  path = field[:path]
  name = field[:label]

  DynamicList(label: name, type_hint: "map[string]string", add_label: name.singularize) { |dl|
    dl.template {
      HStack(spacing: 4, align: "center", data: { "schema-array-target": "item" }) {
        Input(placeholder: "key", name: "#{path}[keys][]")
        Input(placeholder: "value", name: "#{path}[values][]")
        Button(size: "mini", color: "red", icon: "x", type: :button, data: { action: "schema-array#remove" })
      }
    }

    field[:values].each do |(k, v)|
      HStack(spacing: 4, align: "center", data: { "schema-array-target": "item" }) {
        Input(placeholder: "key", value: k.to_s, name: "#{path}[keys][]")
        Input(placeholder: "value", value: v.to_s, name: "#{path}[values][]")
        Button(size: "mini", color: "red", icon: "x", type: :button, data: { action: "schema-array#remove" })
      }
    end
  }

else
  method_name = field[:method].to_s.camelize.to_sym
  if field[:method] == :select
    send(method_name, field[:attr], field[:choices], field[:options].compact)
  else
    send(method_name, field[:attr], field[:options].compact)
  end
end
