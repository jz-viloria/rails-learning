Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "products#index"
  
  # Products routes - this is where we'll list and show products
  resources :products, only: [:index, :show]
  
  # Orders routes - for handling purchases
  resources :orders, only: [:new, :create, :show]
  
  # About page
  get "about", to: "pages#about"
end
