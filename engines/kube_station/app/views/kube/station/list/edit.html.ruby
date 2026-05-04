Menu(attached: "top") {
  BackButton(href: cluster_group_version_kind_list_path(@cluster, params[:group_id], params[:version_id], @kind_name, @item[:metadata][:name], namespace: @item[:metadata][:namespace]), icon: "arrow left")
  MenuItem(header: true) { text "Edit #{@kind_name}" }
}

if @error.present?
  Message(color: :red) {
    Paragraph { text @error }
  }
end

Partial("form")
