Kube::Station::Engine.routes.draw do
  resources :approved, only: [:index, :new, :create, :destroy], path: "resources/approved"

  resources :clusters, only: [:index] do
    resources :groups, only: [:index], constraints: { id: /[^\/]+/ } do
      resources :versions, only: [:index] do
        resources :kinds, only: [:index] do
          resources :list, only: [:index, :show, :new, :edit, :create, :update], constraints: { id: /[^\/]+/ }
        end
      end
    end
  end

  get "graph", to: "graph#show"
  get "graph/node/:uid", to: "graph/node#show", as: :graph_node
end
