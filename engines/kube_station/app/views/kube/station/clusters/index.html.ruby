Menu(attached: "top") {
  MenuItem(header: true) { text "Clusters" }
  MenuItem(href: new_cluster_path, icon: "plus", data: { turbo_frame: "modal" }) { text "Add Cluster" }
}

Table(celled: true, striped: true, rows: @clusters) { |c|
  c.column(:name, heading: "Name") { |cluster|
    LinkTo(href: cluster_groups_path(cluster)) { text cluster.name }
  }
  c.column(:actions, heading: "") { |cluster|
    LinkTo(href: edit_cluster_path(cluster), data: { turbo_frame: "modal" }) { text "Edit" }
  }
}
