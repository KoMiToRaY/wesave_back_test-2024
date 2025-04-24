Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  root 'home#index'

  resources :customers, only: [:show] do
    resources :portfolios, only: [:index]
  end

  resources :portfolios, only: [] do
    member do
      get :arbitrage
      get :historical_values
      post :deposit
      post :withdraw
      post :move
    end
  end

  namespace :api do
    namespace :v1 do
      resources :customers, only: [] do
        resources :portfolios, only: [:index]
      end

      resources :portfolios, only: [:index] do
        post :deposit, on: :member
        post :withdraw, on: :member
        post :move, on: :member
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
