TurboFrame(id: "modal") {
  Header(size: :h3) { text "Edit Cluster" }
  Partial("form", cluster: @cluster, url: cluster_path(@cluster), submit_label: "Update Cluster")
}
