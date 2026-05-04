module Kube
  module Station
    class ClustersController < ApplicationController
      before_action :set_cluster, only: [:edit, :update]

      def index
        @clusters = Cluster.all
      end

      def new
        @cluster = Cluster.new
        @cluster.build_config
      end

      def create
        @config = Config.new(config_params)

        if @config.save
          @cluster = @config.clusters.new(cluster_params)
          if @cluster.save
            redirect_to clusters_path
          else
            @config.destroy
            render :new, status: :unprocessable_entity
          end
        else
          @cluster = Cluster.new(cluster_params)
          @cluster.build_config
          @cluster.config.errors.merge!(@config.errors)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        config = @cluster.config

        if config.update(config_params) && @cluster.update(cluster_params)
          redirect_to clusters_path
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def set_cluster
        @cluster = Cluster.find(params[:id])
      end

      def cluster_params
        params.require(:cluster).permit(:name)
      end

      def config_params
        params.require(:cluster).permit(:kubeconfig).then do |p|
          { name: params[:cluster][:name], data: p[:kubeconfig] }
        end
      end
    end
  end
end
