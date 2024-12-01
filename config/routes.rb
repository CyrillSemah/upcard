Rails.application.routes.draw do
  # Authentication routes (via Devise)
  devise_for :users

  # Root route
  root "home#home"

  # Active Storage route
  if Rails.env.development?
    # Mount Active Storage routes in development
    mount ActiveStorage::Engine => "/rails/active_storage"
  end

  # Resource routes
  resources :cards do
    # Nested routes for invitations
    resources :invitations, only: [:create, :update, :destroy] do
      member do
        get :respond   # Route to respond to an invitation
        post :accept   # Route to accept an invitation
        post :decline  # Route to decline an invitation
      end
    end
  end

  # Direct invitation token route
  get "/invitations/:token", to: "invitations#show", as: :invitation

  # API routes (v1 namespace)
  namespace :api do
    namespace :v1 do
      resources :cards, only: [:index, :show, :create, :update, :destroy]
      resources :invitations, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # Development-only routes for serving images locally
  if Rails.env.development?
    get "images/development/:filename", to: "development#serve_image"
  end

  # Health check route for monitoring app status
  get "up" => "rails/health#show", as: :rails_health_check
end
