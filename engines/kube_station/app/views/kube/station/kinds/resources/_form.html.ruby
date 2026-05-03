Segment(raised: true) {
  Form(
    url: @data&.dig(:metadata, :name) ? kind_resource_path(@kind, @data[:metadata][:name]) : kind_resources_path(@kind),
    method: @data&.dig(:metadata, :name) ? :patch : :post,
    data: {
      controller: "fui-form",
      turbo_action: "replace",
      turbo_frame: "_top"
    }
  ) {
    @fields.each do |field|
      Partial(partial: "schema_field", locals: { field: field })
    end

    Divider()

    Button(variant: :primary, type: :submit) {
      text @data&.dig(:metadata, :name) ? "Save Changes" : "Create #{@kind.kind}"
    }
    Button(type: :button, href: kind_resources_path(@kind)) { text "Cancel" }
  }
}
