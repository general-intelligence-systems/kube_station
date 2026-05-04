module Kube
  module Station
    class KindsController < ApplicationController
      before_action :set_cluster

      def index
        @group = params[:group_id]
        @version = params[:version_id]
        group_match = @group == "core" ? "" : @group
        @kinds = fetch_api_resources
          .select { |r| (r[:group] || "") == group_match && r[:version] == @version }
          .sort_by { |r| r[:kind] }
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
