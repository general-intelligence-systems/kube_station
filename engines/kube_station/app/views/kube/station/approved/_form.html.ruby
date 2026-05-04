Segment {
  Form(
    model: kind,
    url: approved_index_path,
    data: {
      controller: "fui-form",
      turbo_action: "replace",
      turbo_frame: "_top"
    }
  ) do
    if kind.errors.any?
      Message(color: :red) {
        kind.errors.full_messages.each do |msg|
          Paragraph { text msg }
        end
      }
    end

    TextField(:kind, placeholder: "e.g. Pod, Deployment, ConfigMap")

    Divider()

    Button(variant: :primary, type: :submit) { text "Add Kind" }
    Button(type: :button, data: { action: "turbo-modal#hide" }) { text "Cancel" }
  end
}
