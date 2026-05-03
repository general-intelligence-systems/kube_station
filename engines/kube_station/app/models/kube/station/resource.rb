module Kube
  module Station
    class Resource < ApplicationRecord
      belongs_to :cluster
    end
  end
end
