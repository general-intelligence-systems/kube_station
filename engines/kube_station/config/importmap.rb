pin_all_from Kube::Station::Engine.root.join("app/javascript/kube/station/controllers"),
  under: "controllers", to: "kube/station/controllers"

pin "@antv/g6", to: 'https://cdn.jsdelivr.net/npm/@antv/g6@5.1.0/+esm'
