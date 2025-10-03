Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"

      # User profile routes
      get 'users/:id', to: 'users#show', as: 'user'
      patch 'users/:id', to: 'users#update'
      put 'users/:id', to: 'users#replace'

      # Trip routes
      get 'trips', to: 'trips#index'
      post 'trips', to: 'trips#create'
      get 'trips/:id', to: 'trips#show', as: 'trip'
      patch 'trips/:id', to: 'trips#update'
      put 'trips/:id', to: 'trips#replace'
      delete 'trips/:id', to: 'trips#destroy'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
