module Kube
  module Station
    module Graph
      class NodeController < ApplicationController
        def show
          @cluster = Cluster.find(params[:cluster_id])
          uid = params[:uid]

          @cluster.resources.each do |resource|
            items = @cluster.list_resources(resource.kind)
            item = items.find { |i| i[:metadata][:uid] == uid }
            if item
              @node = item
              @kind = resource.kind
              break
            end
          end
        end
      end
    end
  end
end
