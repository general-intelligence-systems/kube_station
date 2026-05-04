Rails.application.routes.draw do
  mount Kube::Station::Engine => "/kube"
end
