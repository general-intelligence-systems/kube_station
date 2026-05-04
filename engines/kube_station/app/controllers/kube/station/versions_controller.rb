module Kube
  module Station
    class VersionsController < ApplicationController
      before_action :set_cluster

      def index
        @group = params[:group_id]
        group_match = @group == "core" ? "" : @group
        @versions = fetch_api_resources
          .select { |r| (r[:group] || "") == group_match }
          .map { |r| r[:version] }.uniq.sort
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
