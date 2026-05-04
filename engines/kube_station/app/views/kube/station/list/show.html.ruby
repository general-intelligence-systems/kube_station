Menu(attached: "top") {
  BackButton(href: cluster_group_version_kind_list_index_path(@cluster, params[:group_id], params[:version_id], @kind_name), icon: "arrow left")
  MenuItem(header: true) { text @item[:metadata][:name] }
  SubMenu(position: "right") {
    MenuItem(href: edit_cluster_group_version_kind_list_path(@cluster, params[:group_id], params[:version_id], @kind_name, @item[:metadata][:name], namespace: @item[:metadata][:namespace]), icon: "edit") { text "Edit" }
  }
}

Segment {
  Header(size: :h3, dividing: true) {
    text @item[:metadata][:name]
    SubHeader { text "#{@kind_name} in #{@item[:metadata][:namespace] || 'cluster'}" }
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
