Rails.application.routes.draw do
  mount Kube::Engine => "/kube"
end
