module Kube
  module Station
    class Engine < ::Rails::Engine
      isolate_namespace Kube::Station
    end
  end
end
