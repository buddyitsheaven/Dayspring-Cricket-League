Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]

  resources :leaderboards, only: :index
  resources :predictions, only: %i[create update]

  resources :password_resets, param: :token, only: %i[new create edit update]

  namespace :admin do
    root "matches#index"
    resources :prediction_submissions, only: :index
    resources :matches, only: %i[index new create edit update] do
      resources :questions, except: %i[index show destroy]
    end
  end
end
