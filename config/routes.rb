Rails.application.routes.draw do
  # devise_for :users
  devise_for :users
  root "products#index"
  resources :products
  resources :checkout, only: [:create]
  post 'checkout/create', to: 'checkout#create', defaults: { format: :html }
  resources :webhooks, only: [:create]
  post '/webhooks', to: 'webhooks#create'
end
