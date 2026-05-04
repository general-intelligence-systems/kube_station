import { Controller } from "@hotwired/stimulus"
//import { Graph, NodeEvent } from '@antv/g6'
//const { Graph } = import "https://unpkg.com/@antv/g6@5/dist/g6.min.js"
const { Graph } = await import("https://esm.sh/@antv/g6@5")

export default class extends Controller {
  connect() {

    const data = {
      nodes: new Array(10).fill(0).map((_, i) => ({ id: `${i}`, label: `${i}` })),
      edges: [
        { source: '0', target: '1' },
        { source: '0', target: '2' },
        { source: '0', target: '3' },
        { source: '0', target: '4' },
        { source: '0', target: '5' },
        { source: '0', target: '7' },
        { source: '0', target: '8' },
        { source: '0', target: '9' },
        { source: '2', target: '3' },
        { source: '4', target: '5' },
        { source: '4', target: '6' },
        { source: '5', target: '6' },
      ],
    };
    
    const graph = new Graph({
      autoFit: {
        type: 'view', // Adaptation type: 'view' or 'center'
        options: {
          // Only applicable to 'view' type
          when: 'overflow', // When to adapt: 'overflow' (only when content overflows) or 'always' (always adapt)
          direction: 'x', // Adaptation direction: 'x', 'y', or 'both'
        },
        animation: {
          // Adaptation animation effect
          duration: 1000, // Animation duration (milliseconds)
          easing: 'ease-in-out', // Animation easing function
        },
      },
      container: 'graph-container',
      node: {
        style: { labelText: (d) => d.id },
      },
      data,
      behaviors: [
        {
          type: 'drag-element-force',
          fixed: true,
        },
        'collapse-expand',
        'focus-element',
        'drag-canvas',
        'zoom-canvas',
        {
          type: 'click-select',
          degree: 1,
          state: 'selected',
          //neighborState: 'active',
          //unselectedState: 'inactive',
          multiple: true,
          trigger: ['shift'],
        },
      ],
      layout: {
        type: 'force',
        gravity: 5,
        speed: 5,
        clustering: true,
        nodeClusterBy: 'cluster',
        preventOverlap: true,
        link: {
          distance: 100,
          strength: 2,
        },
        collide: {
          radius: 40,
        },
      },
      edge: {
        style: {
          stroke: '#e2e2e2',
        },
      },
    });

    graph.render();
  }
}
//  // WebSocket Watch
//  const clusterId = #{@cluster&.id || "null"};
//  const statusBar = document.getElementById("status-bar");
//
//  if (!clusterId) {
//    statusBar.textContent = "No cluster found";
//  } else {
//    const url = (location.protocol === "https:" ? "wss:" : "ws:") + "//" + location.host + "/cable";
//    const ws = new WebSocket(url);
//
//    ws.onopen = () => {
//      statusBar.textContent = "Connected — subscribing...";
//      statusBar.style.color = "#ff0";
//
//      const resources = [
//        "/v1/pods",
//        "/v1/services",
//        "/v1/configmaps",
//        "/v1/secrets",
//        "/v1/namespaces",
//        "/v1/nodes",
//        "apps/v1/deployments",
//        "apps/v1/replicasets",
//        "apps/v1/statefulsets",
//        "apps/v1/daemonsets",
//        "batch/v1/jobs",
//        "batch/v1/cronjobs",
//        "networking.k8s.io/v1/ingresses",
//      ];
//      const identifier = JSON.stringify({
//        channel: "Kube::Station::WatchChannel",
//        cluster_id: clusterId,
//        resources: resources
//      });
//      ws.send(JSON.stringify({ command: "subscribe", identifier: identifier }));
//    };
//
//    ws.onmessage = (e) => {
//      const data = JSON.parse(e.data);
//
//      if (data.type === "welcome") {
//        statusBar.textContent = "Connected — welcomed";
//        return;
//      }
//      if (data.type === "confirm_subscription") {
//        statusBar.textContent = "Subscribed — waiting for events...";
//        statusBar.style.color = "#0f0";
//        return;
//      }
//      if (data.type === "reject_subscription") {
//        statusBar.textContent = "Subscription rejected!";
//        statusBar.style.color = "#f00";
//        return;
//      }
//      if (data.type === "disconnect") return;
//      if (data.type === "ping") return;
//    };
//
//    ws.onclose = () => {
//      statusBar.textContent = "Disconnected";
//      statusBar.style.color = "#f00";
//    };
//
//    ws.onerror = () => {
//      statusBar.textContent = "WebSocket error";
//      statusBar.style.color = "#f00";
//    };
//  }
//^.html_safe }
