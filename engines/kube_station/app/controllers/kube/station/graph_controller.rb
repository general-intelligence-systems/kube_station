module Kube
  module Station
    class GraphController < ApplicationController
      def show
        @cluster = Cluster.find(params[:cluster_id])

        nodes = {}
        edges = []

        @cluster.resources.each do |resource|
          items = @cluster.list_resources(resource.kind)
          items.each do |item|
            meta = item[:metadata]
            uid = meta[:uid]
            nodes[uid] = {
              id: uid,
              label: meta[:name],
              kind: resource.kind,
              namespace: meta[:namespace],
              size: 20
            }

            (meta[:ownerReferences] || []).each do |ref|
              edges << { source: ref[:uid], target: uid }
            end
          end
        end

        edges.select! { |e| nodes.key?(e[:source]) && nodes.key?(e[:target]) }
        @graph_data = { nodes: nodes.values, edges: edges }.to_json
      end

    end
  end
end
