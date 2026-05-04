Segment {
  Form(
    model: cluster,
    url: url,
    data: {
      controller: "fui-form",
      turbo_action: "replace",
      turbo_frame: "_top"
    }
  ) do
    if cluster.errors.any?
      Message(color: :red) {
        cluster.errors.full_messages.each do |msg|
          Paragraph { text msg }
        end
      }
    end

    TextField(:name, placeholder: "e.g. production, staging")
    TextArea(:kubeconfig, placeholder: "Paste kubeconfig YAML here", value: cluster.config&.data)

    Divider()

    Button(variant: :primary, type: :submit) { text submit_label }
    Button(type: :button, data: { action: "turbo-modal#hide" }) { text "Cancel" }
  end
}
