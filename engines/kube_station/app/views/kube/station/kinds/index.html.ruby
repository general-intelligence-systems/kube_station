Menu(attached: "top") {
  MenuItem(header: true) { text "Kinds" }
  MenuItem(href: new_kind_path, icon: "plus", data: { turbo_frame: "modal" }) { text "Add Kind" }
}

Table(celled: true, striped: true, rows: @kinds) { |c|
  c.column(:kind, heading: "Kind") { |kind|
    LinkTo(href: kind_resources_path(kind)) { text kind.kind }
  }
  c.column(:created_at, heading: "Added") { |kind|
    text kind.created_at&.strftime("%Y-%m-%d")
  }
  c.column(:actions, heading: "") { |kind|
    ButtonTo(url: kind_path(kind), method: :delete, color: "red", size: "mini", confirm: "Remove #{kind.kind}?") { text "Remove" }
  }
}
