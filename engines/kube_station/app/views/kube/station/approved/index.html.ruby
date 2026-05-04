Menu(attached: "top") {
  MenuItem(header: true) { text "Approved Resources" }
  MenuItem(href: new_approved_path, icon: "plus", data: { turbo_frame: "modal" }) { text "Add Kind" }
}

Table(celled: true, striped: true, rows: @kinds) { |c|
  c.column(:kind, heading: "Kind") { |kind|
    text kind.kind
  }
  c.column(:created_at, heading: "Added") { |kind|
    text kind.created_at&.strftime("%Y-%m-%d")
  }
  c.column(:actions, heading: "") { |kind|
    ButtonTo(url: approved_path(kind), method: :delete, color: "red", size: "mini", confirm: "Remove #{kind.kind}?") { text "Remove" }
  }
}
