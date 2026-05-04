module Kube
  module Station
    class ListController < ApplicationController
      before_action :set_cluster
      before_action :set_kind_name
      before_action :set_namespaces, only: [:index]
      before_action :set_item, only: [:show, :edit, :update]

      def index
        @items = list_items
      rescue => e
        @error = e.message
        @items = []
      end

      def show
      end

      def new
        @data = ::Kube::Schema[@kind_name].defaults.merge({})
        @fields = SchemaFields.call(resolve_schema(@kind_name), @data)
      end

      def edit
        @fields = SchemaFields.call(resolve_schema(@kind_name), @data)
      end

      def create
        resource_hash = build_resource_hash(params[:resource])
        resource = ::Kube::Schema[@kind_name].new(resource_hash)
        @cluster.apply_resource(resource.to_h)
        redirect_to cluster_group_version_kind_list_index_path(@cluster, params[:group_id], params[:version_id], @kind_name)
      rescue => e
        @error = e.message
        @data = resource_hash || {}
        @fields = SchemaFields.call(resolve_schema(@kind_name), @data)
        render :new, status: :unprocessable_entity
      end

      def update
        resource_hash = build_resource_hash(params[:resource])
        resource = ::Kube::Schema[@kind_name].new(resource_hash)
        @cluster.apply_resource(resource.to_h)
        redirect_to cluster_group_version_kind_list_path(@cluster, params[:group_id], params[:version_id], @kind_name, resource.to_h[:metadata][:name])
      rescue => e
        @error = e.message
        @data = resource_hash || @data
        @fields = SchemaFields.call(resolve_schema(@kind_name), @data)
        render :edit, status: :unprocessable_entity
      end

      private

      def set_cluster
        @cluster = Cluster.find(params[:cluster_id])
      end

      def set_kind_name
        @kind_name = params[:kind_id]
      end

      def list_items
        @cluster.with_connection do |instance|
          ctl = instance.connection.ctl
          cmd = "get #{@kind_name} -o json"
          if params[:namespace].present?
            cmd += " -n #{params[:namespace]}"
          else
            cmd += " --all-namespaces"
          end
          json = ctl.run(cmd)
          parsed = JSON.parse(json, symbolize_names: true)
          parsed[:items] || []
        end
      end

      def set_namespaces
        @namespaces = @cluster.with_connection do |instance|
          ctl = instance.connection.ctl
          json = ctl.run("get namespaces -o json")
          parsed = JSON.parse(json, symbolize_names: true)
          (parsed[:items] || []).map { |ns| ns[:metadata][:name] }
        end
      rescue
        @namespaces = []
      end

      def set_item
        @cluster.with_connection do |instance|
          ctl = instance.connection.ctl
          cmd = "get #{@kind_name} #{params[:id]} -o json"
          cmd += " -n #{params[:namespace]}" if params[:namespace]
          json = ctl.run(cmd)
          @item = JSON.parse(json, symbolize_names: true)
          @data = @item
        end
      end

      def build_resource_hash(resource_params)
        clean_params(convert_maps(resource_params.to_unsafe_h))
      end

      def convert_maps(obj)
        case obj
        when Hash
          if obj.key?("keys") && obj.key?("values") && obj.keys.sort == %w[keys values]
            keys = Array(obj["keys"])
            values = Array(obj["values"])
            keys.zip(values).reject { |k, _| k.blank? }.to_h
          else
            obj.transform_values { |v| convert_maps(v) }
          end
        when Array
          obj.map { |v| convert_maps(v) }.reject { |v| v == "" }
        else
          obj
        end
      end

      def clean_params(obj)
        case obj
        when Hash
          obj.each_with_object({}) do |(k, v), result|
            cleaned = clean_params(v)
            result[k] = cleaned unless cleaned == "" || (cleaned.is_a?(Hash) && cleaned.empty?)
          end
        when Array
          obj.map { |v| clean_params(v) }
        else
          obj
        end
      end

      def resolve_schema(kind_name)
        klass = ::Kube::Schema[kind_name]
        klass.schema
      end
    end
  end
end
