Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]

  resources :community_votes, only: %i[index show]
  resources :leaderboards, only: :index
  resources :predictions, only: %i[create update]

  namespace :admin do
    root "matches#index"
    resources :prediction_submissions, only: :index
    resources :matches, only: %i[index new create edit update] do
      resources :questions, except: %i[index show destroy]
    end
  end
end
