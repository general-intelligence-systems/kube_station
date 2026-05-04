module Kube
  module Station
    class Engine < ::Rails::Engine
      isolate_namespace Kube::Station
      require "scampi/kernel_ext"
      require "kube/cluster"

      initializer "kube_station.assets" do |app|
        ui_gem = Gem::Specification.find_by_name("rails-active-ui")
        app.config.assets.paths << File.join(ui_gem.gem_dir, "app", "assets")
        app.config.assets.paths << root.join("app/javascript")
      end

      initializer "kube_station.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
        end
      end
    end
  end
end
