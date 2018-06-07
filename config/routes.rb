Rails.application.routes.draw do
  root to: 'visitors#index'
  resources :users
  resources :sessions, only: %w(new create destroy)
  resources :transactions, only: %w(new create)
end
