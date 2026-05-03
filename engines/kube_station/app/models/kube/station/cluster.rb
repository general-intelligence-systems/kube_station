module Kube
  module Station
    class Cluster < ApplicationRecord
      belongs_to :config
      has_many :resources, dependent: :destroy

      def with_connection
        config.with_kubeconfig_file do |path|
          yield ::Kube::Cluster.connect(kubeconfig: path)
        end
      end

      def list_resources(kind)
        with_connection do |instance|
          ctl = instance.connection.ctl
          json = ctl.run("get #{kind.downcase.pluralize} -o json")
          parsed = JSON.parse(json, symbolize_names: true)
          parsed[:items] || []
        end
      end

      def get_resource(kind, name, namespace: nil)
        with_connection do |instance|
          ctl = instance.connection.ctl
          cmd = "get #{kind.downcase} #{name} -o json"
          cmd += " -n #{namespace}" if namespace
          json = ctl.run(cmd)
          JSON.parse(json, symbolize_names: true)
        end
      end

      def apply_resource(data)
        with_connection do |instance|
          ctl = instance.connection.ctl
          json = JSON.generate(data)
          ctl.run("apply -f - --stdin #{json}")
        end
      end
    end
  end
end
