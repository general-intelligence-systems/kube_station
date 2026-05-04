Menu(attached: "top") {
  BackButton(href: cluster_group_version_kinds_path(@cluster, params[:group_id], params[:version_id]), icon: "arrow left")
  MenuItem(header: true) { text @kind_name }
  MenuItem(href: new_cluster_group_version_kind_list_path(@cluster, params[:group_id], params[:version_id], @kind_name), icon: "plus") { text "New" }
  MenuItem(position: "right") {
    select_tag :namespace,
      options_for_select([["All Namespaces", ""]] + @namespaces.map { |ns| [ns, ns] }, params[:namespace]),
      onchange: "Turbo.visit(window.location.pathname + (this.value ? '?namespace=' + this.value : ''))",
      class: "ui dropdown"
  }
}

if @error.present?
  Message(color: :red) {
    Paragraph { text @error }
  }
end

Table(celled: true, striped: true, rows: @items) { |c|
  c.column(:name, heading: "Name") { |item|
    LinkTo(href: cluster_group_version_kind_list_path(@cluster, params[:group_id], params[:version_id], @kind_name, item[:metadata][:name], namespace: item[:metadata][:namespace])) {
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
