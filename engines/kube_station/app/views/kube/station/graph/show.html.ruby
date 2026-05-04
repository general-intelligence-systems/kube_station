ContentFor(:head) {
  Script(src: "https://unpkg.com/@antv/g6@5/dist/g6.min.js")
}

#Wrapper(id: "status-bar") { text "Disconnected" }

HStack() {
  Wrapper() {
    Wrapper(id: "graph-container")
  }
  Wrapper() {
    TurboFrame(id: "node-panel")
  }
}

Script { text %^
  // G6 Graph
  const { Graph, NodeEvent } = G6;

  const data = #{@graph_data};

  const graph = new Graph({
    container: 'graph-container',
    data,
    autoFit: 'view',
    modes: {
      default: ['drag-canvas', 'zoom-canvas'],
    },
    layout: {
      type: 'force',
      preventOverlap: true,
      nodeSize: 20,
      gravity: 0.9,
      iterations: 100,
    },
    node: {
      style: {
        size: (d) => d.size,
        fill: '#9EC9FF',
        stroke: '#69C8FF',
        label: (d) => d.label,
        labelPlacement: 'center',
        labelFill: '#333',
      },
    },
    edge: {
      style: {
        stroke: '#e2e2e2',
      },
    },
  });

  let selectedNodeId = null;

  graph.on(NodeEvent.CLICK, (e) => {
    const nodeId = e.target.id;
    const updates = [];

    if (selectedNodeId) {
      updates.push({ id: selectedNodeId, style: { fill: '#9EC9FF', stroke: '#69C8FF', lineWidth: 1 } });
    }

    selectedNodeId = nodeId;
    updates.push({ id: nodeId, style: { fill: '#1E90FF', stroke: '#0050AA', lineWidth: 3 } });
    graph.updateNodeData(updates);
    graph.draw();

    //document.getElementById("node-panel-wrapper").classList.add("open");
    document.getElementById("node-panel").src = "#{graph_node_path('__UID__')}".replace("__UID__", nodeId);
  });

  graph.render();

^.html_safe }

#  // WebSocket Watch
#  const clusterId = #{@cluster&.id || "null"};
#  const statusBar = document.getElementById("status-bar");
#
#  if (!clusterId) {
#    statusBar.textContent = "No cluster found";
#  } else {
#    const url = (location.protocol === "https:" ? "wss:" : "ws:") + "//" + location.host + "/cable";
#    const ws = new WebSocket(url);
#
#    ws.onopen = () => {
#      statusBar.textContent = "Connected — subscribing...";
#      statusBar.style.color = "#ff0";
#
#      const resources = [
#        "/v1/pods",
#        "/v1/services",
#        "/v1/configmaps",
#        "/v1/secrets",
#        "/v1/namespaces",
#        "/v1/nodes",
#        "apps/v1/deployments",
#        "apps/v1/replicasets",
#        "apps/v1/statefulsets",
#        "apps/v1/daemonsets",
#        "batch/v1/jobs",
#        "batch/v1/cronjobs",
#        "networking.k8s.io/v1/ingresses",
#      ];
#      const identifier = JSON.stringify({
#        channel: "Kube::Station::WatchChannel",
#        cluster_id: clusterId,
#        resources: resources
#      });
#      ws.send(JSON.stringify({ command: "subscribe", identifier: identifier }));
#    };
#
#    ws.onmessage = (e) => {
#      const data = JSON.parse(e.data);
#
#      if (data.type === "welcome") {
#        statusBar.textContent = "Connected — welcomed";
#        return;
#      }
#      if (data.type === "confirm_subscription") {
#        statusBar.textContent = "Subscribed — waiting for events...";
#        statusBar.style.color = "#0f0";
#        return;
#      }
#      if (data.type === "reject_subscription") {
#        statusBar.textContent = "Subscription rejected!";
#        statusBar.style.color = "#f00";
#        return;
#      }
#      if (data.type === "disconnect") return;
#      if (data.type === "ping") return;
#    };
#
#    ws.onclose = () => {
#      statusBar.textContent = "Disconnected";
#      statusBar.style.color = "#f00";
#    };
#
#    ws.onerror = () => {
#      statusBar.textContent = "WebSocket error";
#      statusBar.style.color = "#f00";
#    };
#  }
#^.html_safe }
