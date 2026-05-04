ContentFor(:head) {
  Script(src: "https://unpkg.com/@antv/g6@5/dist/g6.min.js")
}

#Wrapper(id: "status-bar") { text "Disconnected" }

Wrapper(style: 'height: 100%; display: flex; width: 100%;') {
  TurboFrame(id: "node-panel") {
    text "click something"
  }
  Wrapper(id: "graph-wrapper", style: 'flex-grow: 2') {
    Wrapper(id: "graph-container", data: {controller: 'graph'}, style: 'height: 100%;')
  }
}

