module Kube
  module Station
    module Kinds
      class ResourcesController < ApplicationController
        before_action :set_cluster
        before_action :set_kind
        before_action :set_item, only: [:show, :edit, :update]

        def index
          @items = @cluster.list_resources(@kind.kind)
        rescue => e
          @error = e.message
          @items = []
        end

        def show
        end

        def new
          @data = ::Kube::Schema[@kind.kind].defaults.merge({})
          @fields = SchemaFields.call(resolve_schema(@kind.kind), @data)
        end

        def edit
          @fields = SchemaFields.call(resolve_schema(@kind.kind), @data)
        end

        def create
          data = JSON.parse(request.body.read)
          @cluster.apply_resource(data)
          redirect_to kind_resources_path(@kind)
        rescue => e
          @error = e.message
          @data = data || {}
          @fields = SchemaFields.call(resolve_schema(@kind.kind), @data)
          render :new, status: :unprocessable_entity
        end

        def update
          data = JSON.parse(request.body.read)
          @cluster.apply_resource(data)
          redirect_to kind_resource_path(@kind, @item[:metadata][:name])
        rescue => e
          @error = e.message
          @fields = SchemaFields.call(resolve_schema(@kind.kind), @data)
          render :edit, status: :unprocessable_entity
        end

        private

        def set_cluster
          @cluster = Cluster.find_by!(name: "default")
        end

        def set_kind
          @kind = @cluster.resources.find(params[:kind_id])
        end

        def set_item
          @item = @cluster.get_resource(@kind.kind, params[:id], namespace: params[:namespace])
          @data = @item
        end

        def resolve_schema(kind)
          klass = ::Kube::Schema[kind]
          klass.schema
        end
      end
    end
  end
end
