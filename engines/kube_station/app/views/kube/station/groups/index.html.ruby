Menu(attached: "top") {
  BackButton(href: clusters_path, icon: "arrow left")
  MenuItem(header: true) { text "API Groups" }
}

Table(celled: true, striped: true, rows: @groups) { |c|
  c.column(:group, heading: "Group") { |group|
    LinkTo(href: cluster_group_versions_path(@cluster, group)) { text group }
  }
}
