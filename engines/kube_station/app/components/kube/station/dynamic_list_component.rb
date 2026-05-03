# frozen_string_literal: true

module Kube
  module Station
    class DynamicListComponent < ::Component
      attribute :label, :string
      attribute :type_hint, :string, default: nil
      attribute :required, :boolean, default: false
      attribute :add_label, :string

      slot :template

      def to_s
        opts = merge_html_options(
          class: "field",
          data: { controller: "schema-array" },
          aria: { live: "polite" }
        )

        tag.div(**opts) {
          safe_join([
            label_row,
            tag.template(data: { "schema-array-target": "template" }) { @slots[:template] },
            tag.div(data: { "schema-array-target": "list" }) { @content },
            tag.button(
              class: "ui mini button", type: "button",
              data: { action: "schema-array#add" }
            ) { safe_join([tag.i(class: "plus icon"), " Add #{add_label}"]) }
          ])
        }
      end

      private

      def label_row
        parts = []
        parts << tag.label("#{label}#{required ? ' *' : ''}", class: "ui small text")
        parts << tag.span(type_hint, class: "ui tiny grey text") if type_hint
        tag.div(style: "display: flex; align-items: center; gap: 4px;") { safe_join(parts) }
      end
    end
  end
end
