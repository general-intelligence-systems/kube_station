module Kube
  module Station
    class GroupsController < ApplicationController
      before_action :set_cluster

      def index
        @groups = fetch_api_resources.map { |r| r[:group].presence || "core" }.uniq.sort
      end

      private

      def set_cluster
        @cluster = Cluster.find(params[:cluster_id])
      end

      def fetch_api_resources
        @cluster.with_connection do |instance|
          json = instance.connection.ctl.run("api-resources -o json")
          JSON.parse(json, symbolize_names: true)[:resources]
        end
      end
    end
  end
end
