module Kube
  module Station
    class Config < ApplicationRecord
      has_many :clusters, dependent: :destroy
    end
  end
end
