# frozen_string_literal: true

module Kube
  module Station
    module ComponentHelper
      def DynamicList(**kwargs, &block)
        output_buffer << render(Kube::Station::DynamicListComponent.new(**kwargs), &block)
      end
    end
  end
end
