require "test_helper"

module Kube
  module Station
    class ListControllerTest < ActionDispatch::IntegrationTest
      setup do
        kubeconfig_path = Kube::Station::Engine.root.join("../../kubeconfig.yaml").to_s
        config = Kube::Station::Config.find_or_create_by!(name: "default") do |c|
          c.data = File.read(kubeconfig_path)
        end
        @cluster = Kube::Station::Cluster.find_or_create_by!(name: "default", config: config)
        @kind = @cluster.resources.find_or_create_by!(kind: "ConfigMap")
      end

      teardown do
        @cluster.with_connection do |instance|
          ctl = instance.connection.ctl
          ctl.run("delete configmap test-cm -n default --ignore-not-found")
        end
      end

      test "create applies a ConfigMap to the cluster via form params" do
        post helpers.cluster_group_version_resource_list_index_path(@cluster, "core", "v1", "ConfigMap"), params: {
          resource: {
            metadata: { name: "test-cm", namespace: "default" },
            data: { keys: ["APP_ENV"], values: ["production"] }
          }
        }

        assert_response :redirect

        item = @cluster.get_resource("ConfigMap", "test-cm", namespace: "default")
        assert_equal "ConfigMap", item[:kind]
        assert_equal "test-cm", item[:metadata][:name]
        assert_equal "production", item[:data][:APP_ENV]
      end

      test "create does not redirect on invalid resource" do
        assert_raises do
          post helpers.cluster_group_version_resource_list_index_path(@cluster, "core", "v1", "ConfigMap"), params: {
            resource: {
              metadata: { name: "", namespace: "default" }
            }
          }
        end
      end

      test "update modifies an existing ConfigMap via form params" do
        post helpers.cluster_group_version_resource_list_index_path(@cluster, "core", "v1", "ConfigMap"), params: {
          resource: {
            metadata: { name: "test-cm", namespace: "default" },
            data: { keys: ["APP_ENV"], values: ["staging"] }
          }
        }
        assert_response :redirect

        patch helpers.cluster_group_version_resource_list_path(@cluster, "core", "v1", "ConfigMap", "test-cm", namespace: "default"), params: {
          resource: {
            metadata: { name: "test-cm", namespace: "default" },
            data: { keys: ["APP_ENV"], values: ["production"] }
          }
        }
        assert_response :redirect

        item = @cluster.get_resource("ConfigMap", "test-cm", namespace: "default")
        assert_equal "production", item[:data][:APP_ENV]
      end

      test "create converts map fields from keys/values arrays to a hash" do
        post helpers.cluster_group_version_resource_list_index_path(@cluster, "core", "v1", "ConfigMap"), params: {
          resource: {
            metadata: {
              name: "test-cm",
              namespace: "default",
              labels: { keys: ["app", "env"], values: ["web", "prod"] }
            },
            data: { keys: ["FOO"], values: ["bar"] }
          }
        }

        assert_response :redirect

        item = @cluster.get_resource("ConfigMap", "test-cm", namespace: "default")
        assert_equal "web", item[:metadata][:labels][:app]
        assert_equal "prod", item[:metadata][:labels][:env]
      end

      private

      def helpers
        Kube::Station::Engine.routes.url_helpers
      end
    end
  end
end
