Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "products#index"

  # Products routes - this is where we'll list and show products
  resources :products, only: [:index, :show]

  # Orders routes - for handling purchases
  resources :orders, only: [:new, :create, :show]

  # Authentication routes
  get "register", to: "authentication#new"
  post "register", to: "authentication#create"
  get "login", to: "authentication#login"
  post "login", to: "authentication#authenticate"
  delete "logout", to: "authentication#logout"
  get "dashboard", to: "authentication#dashboard"

  # Admin routes
  namespace :admin do
    resources :products
  end

  # About page
  get "about", to: "pages#about"
end
