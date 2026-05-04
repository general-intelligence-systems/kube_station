module Kube
  module Station
    class ApprovedController < ApplicationController
      before_action :set_cluster
      before_action :set_kind, only: :destroy

      def index
        @kinds = @cluster.resources
      end

      def new
        @kind = @cluster.resources.new
      end

      def create
        @kind = @cluster.resources.new(kind_params)

        if @kind.save
          redirect_to approved_index_path
        else
          render :new, status: :unprocessable_entity
        end
      end

      def destroy
        @kind.destroy
        redirect_to approved_index_path
      end

      private

      def set_cluster
        @cluster = Cluster.find_by!(name: "default")
      end

      def set_kind
        @kind = @cluster.resources.find(params[:id])
      end

      def kind_params
        params.require(:resource).permit(:kind)
      end
    end
  end
end
