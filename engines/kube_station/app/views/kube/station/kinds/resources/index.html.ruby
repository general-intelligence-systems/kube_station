Menu(attached: "top") {
  BackButton(href: kinds_path, icon: "arrow left")
  MenuItem(header: true) { text @kind.kind }
  MenuItem(href: new_kind_resource_path(@kind), icon: "plus") { text "New" }
}

if @error.present?
  Message(color: :red) {
    Paragraph { text @error }
  }
end

Table(celled: true, striped: true, rows: @items) { |c|
  c.column(:name, heading: "Name") { |item|
    LinkTo(href: kind_resource_path(@kind, item[:metadata][:name], namespace: item[:metadata][:namespace])) {
      text item[:metadata][:name]
    }
  }
  c.column(:namespace, heading: "Namespace") { |item|
    if item[:metadata][:namespace]
      text item[:metadata][:namespace]
    else
      Text(color: "grey") { text "—" }
    end
  }
  c.column(:created, heading: "Created") { |item|
    if item[:metadata][:creationTimestamp]
      text item[:metadata][:creationTimestamp]
    else
      Text(color: "grey") { text "—" }
    end
  }
}
