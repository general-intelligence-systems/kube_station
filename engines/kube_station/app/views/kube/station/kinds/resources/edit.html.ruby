Menu(attached: "top") {
  BackButton(href: kind_resource_path(@kind, @item[:metadata][:name], namespace: @item[:metadata][:namespace]), icon: "arrow left")
  MenuItem(header: true) { text "Edit #{@kind.kind}" }
}

if @error.present?
  Message(color: :red) {
    Paragraph { text @error }
  }
end

Partial("form")
