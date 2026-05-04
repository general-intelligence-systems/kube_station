Menu(attached: "top") {
  BackButton(href: cluster_group_version_kind_list_index_path(@cluster, params[:group_id], params[:version_id], @kind_name), icon: "arrow left")
  MenuItem(header: true) { text "New #{@kind_name}" }
}

if @error.present?
  Message(color: :red) {
    Paragraph { text @error }
  }
end

Partial("form")
