Menu(attached: "top") {
  MenuItem(header: true) { text "Clusters" }
}

Table(celled: true, striped: true, rows: @clusters) { |c|
  c.column(:name, heading: "Name") { |cluster|
    LinkTo(href: cluster_groups_path(cluster)) { text cluster.name }
  }
}
