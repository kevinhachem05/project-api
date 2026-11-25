Rails.application.routes.draw do
  apipie

  namespace :api do
    namespace :v1 do
      resources :users, only: :create
      resource :me, only: :show, controller: :me
      resources :sessions, only: %i[create show destroy]
      resources :email_verifications, only: %i[create update]
    end
  end

  devise_for :users,
             skip: %i[registrations passwords],
             controllers: { sessions: "admin/sessions" }

  authenticate :user, ->(user) { user.platform_admin? && user.active? } do
    mount Motor::Admin => "/admin"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
