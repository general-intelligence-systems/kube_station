module Kube
  module Station
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
