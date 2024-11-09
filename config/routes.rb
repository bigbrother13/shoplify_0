Rails.application.routes.draw do
  devise_for :users
  root "products#index"
  resources :products
  resources :checkout, only: [:create]
  post 'checkout/create', to: 'checkout#create', defaults: { format: :html }
  resources :webhooks, only: [:create]
  post '/webhooks', to: 'webhooks#create'
  get "seccess", to: "checkout#seccess"
  get "cancel", to: "checkout#cancel"

end
