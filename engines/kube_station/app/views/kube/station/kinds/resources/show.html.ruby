Menu(attached: "top") {
  BackButton(href: kind_resources_path(@kind), icon: "arrow left")
  MenuItem(header: true) { text @item[:metadata][:name] }
  SubMenu(position: "right") {
    MenuItem(href: edit_kind_resource_path(@kind, @item[:metadata][:name], namespace: @item[:metadata][:namespace]), icon: "edit") { text "Edit" }
  }
}

Segment {
  Header(size: :h3, dividing: true) {
    text @item[:metadata][:name]
    SubHeader { text "#{@kind.kind} in #{@item[:metadata][:namespace] || 'cluster'}" }
  }

  Table(celled: true, definition: true) { |c|
    c.header {
      TableRow {
        TableCell(heading: true) { text "Field" }
        TableCell(heading: true) { text "Value" }
      }
    }

    TableRow {
      TableCell { Header(size: :h5) { text "API Version" } }
      TableCell { text @item[:apiVersion].to_s }
    }
    TableRow {
      TableCell { Header(size: :h5) { text "Kind" } }
      TableCell { text @item[:kind].to_s }
    }
    TableRow {
      TableCell { Header(size: :h5) { text "Name" } }
      TableCell { text @item[:metadata][:name].to_s }
    }
    TableRow {
      TableCell { Header(size: :h5) { text "Namespace" } }
      TableCell { text @item[:metadata][:namespace].to_s }
    }
    TableRow {
      TableCell { Header(size: :h5) { text "Created" } }
      TableCell { text @item[:metadata][:creationTimestamp].to_s }
    }
  }

  Divider()

  Accordion { |a|
    a.title { text "Full JSON" }
    Wrapper(style: "overflow: auto; max-height: 500px;") {
      Pre { text JSON.pretty_generate(@item) }
    }
  }
}
