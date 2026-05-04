TurboFrame(id: "modal") {
  Header(size: :h3) { text "Add Cluster" }
  Partial("form", cluster: @cluster, url: clusters_path, submit_label: "Add Cluster")
}
