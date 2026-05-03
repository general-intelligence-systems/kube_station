module Kube
  module Station
    class Engine < ::Rails::Engine
      isolate_namespace Kube::Station
      require "scampi/kernel_ext"
      require "kube/cluster"

      initializer "kube_station.assets" do |app|
        ui_gem = Gem::Specification.find_by_name("rails-active-ui")
        app.config.assets.paths << File.join(ui_gem.gem_dir, "app", "assets")
      end
    end
  end
end
