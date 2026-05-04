module Kube
  module Station
    class ClustersController < ApplicationController
      def index
        @clusters = Cluster.all
      end
    end
  end
end
