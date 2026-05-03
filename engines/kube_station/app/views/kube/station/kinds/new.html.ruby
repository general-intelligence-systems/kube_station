TurboFrame(id: "modal") {
  Header(size: :h3) { text "Add Kind" }
  Partial("form", kind: @kind)
}
