Kube::Station::Engine.routes.draw do
  resources :kinds, only: [:index, :new, :create, :destroy] do
    resources :resources, only: [:index, :show, :new, :edit, :create, :update], module: :kinds
  end
end
