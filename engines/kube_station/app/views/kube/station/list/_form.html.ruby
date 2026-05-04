Segment(raised: true) {
  Form(
    url: @data&.dig(:metadata, :name) ? cluster_group_version_kind_list_path(@cluster, params[:group_id], params[:version_id], @kind_name, @data[:metadata][:name]) : cluster_group_version_kind_list_index_path(@cluster, params[:group_id], params[:version_id], @kind_name),
    method: @data&.dig(:metadata, :name) ? :patch : :post,
    data: {
      turbo_action: "replace",
      turbo_frame: "_top"
    }
  ) {
    @fields.each do |field|
      Partial(partial: "schema_field", locals: { field: field })
    end

    Divider()

    Button(variant: :primary, type: :submit) {
      text @data&.dig(:metadata, :name) ? "Save Changes" : "Create #{@kind_name}"
    }
    Button(type: :button, href: cluster_group_version_kind_list_index_path(@cluster, params[:group_id], params[:version_id], @kind_name)) { text "Cancel" }
  }
}
