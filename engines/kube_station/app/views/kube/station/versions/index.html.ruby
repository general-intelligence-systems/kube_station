Menu(attached: "top") {
  BackButton(href: cluster_groups_path(@cluster), icon: "arrow left")
  MenuItem(header: true) { text "#{@group} — Versions" }
}

Table(celled: true, striped: true, rows: @versions) { |c|
  c.column(:version, heading: "Version") { |version|
    LinkTo(href: cluster_group_version_kinds_path(@cluster, @group, version)) { text version }
  }
}
