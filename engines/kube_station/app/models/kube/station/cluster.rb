module Kube
  module Station
    class Cluster < ApplicationRecord
      belongs_to :config
      has_many :resources, dependent: :destroy
    end
  end
end
