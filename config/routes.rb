Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :properties, only: [:index, :show, :create]
      post "payments/payment_link", to: "payments#payment_link"
      post "properties/create_property", to: "properties#create_property"
      resources :payments, only: [:index, :show, :create]
    end
  end
  resources :webhooks, only: [:create]
  namespace :connect do
    resources :webhooks, only: [:create]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
