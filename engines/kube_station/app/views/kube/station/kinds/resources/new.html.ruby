Menu(attached: "top") {
  BackButton(href: kind_resources_path(@kind), icon: "arrow left")
  MenuItem(header: true) { text "New #{@kind.kind}" }
}

if @error.present?
  Message(color: :red) {
    Paragraph { text @error }
  }
end

Partial("form")
