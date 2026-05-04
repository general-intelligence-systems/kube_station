Menu(attached: "top") {
  BackButton(href: cluster_group_versions_path(@cluster, @group), icon: "arrow left")
  MenuItem(header: true) { text "#{@group}/#{@version} — Resources" }
}

Table(celled: true, striped: true, rows: @kinds) { |c|
  c.column(:kind, heading: "Kind") { |kind|
    LinkTo(href: cluster_group_version_kind_list_index_path(@cluster, @group, @version, kind[:kind])) {
      text kind[:kind]
    }
  }
  c.column(:name, heading: "Plural Name") { |kind|
    text kind[:name]
  }
  c.column(:namespaced, heading: "Namespaced") { |kind|
    text kind[:namespaced] ? "Yes" : "No"
  }
}
