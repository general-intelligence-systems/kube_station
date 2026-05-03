# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
DEFAULT_KUBECONFIG_YAML = File.expand_path("kubeconfig.yaml", Rails.root)

unless File.exist?(DEFAULT_KUBECONFIG_YAML)
  system("#{Rails.root}/bin/dev")

  until File.exist?(DEFAULT_KUBECONFIG_YAML)
    puts "waiting for kubeconfig.yaml to be created..."
    sleep 1
  end
end

default_config = Kube::Station::Config.find_by(name: "default")

if default_config.present?
  default_config.update!(data: File.read(DEFAULT_KUBECONFIG_YAML))

else
  default_config =
    Kube::Station::Config.create!(
      name: "default",
      data: File.read(DEFAULT_KUBECONFIG_YAML),
    )
end


default_cluster =
  Kube::Station::Cluster.find_or_create_by!(
    name: "default",
    config: default_config,
  )

%w[

  Pod
  Deployment
  ConfigMap

].each do |kind|
  Kube::Station::Resource.find_or_create_by!(
    kind: kind,
    cluster: default_cluster,
  )
end
