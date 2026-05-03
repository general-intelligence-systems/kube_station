module Kube
  module Station
    class Config < ApplicationRecord
      has_many :clusters, dependent: :destroy

      def with_kubeconfig_file
        file = Tempfile.new(["kubeconfig", ".yaml"])
        file.write(data)
        file.close
        yield file.path
      ensure
        file&.unlink
      end
    end
  end
end
