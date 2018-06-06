Rails.application.routes.draw do
  get 'sessions/new'
  root to: 'visitors#index'
  resources :users
  resources :sessions, only: %w(new create destroy)
end
