Rails.application.routes.draw do
  scope "(:locale)", locale: /en|ja|vi/ do
    root "static_pages#home"
    get "help" => "static_pages#help"
    get "signup" => "users#new"
    get "login" => "sessions#new"
    post "login" => "sessions#create"
    delete "logout" => "sessions#destroy"
    resources :users
    resources :relationships, only: [:create, :destroy]
    resources :categories, only: [:index]
    resources :user_goals
    namespace :admin do
      root "users#index"
      resources :users, except: [:new, :create, :edit]
      resources :words, except: [:new, :show, :destroy]
    end
    resources :lessons, except: [:new, :create, :destroy]
    resources :categories do
      resources :lessons, only: :create
      resources :words, only: :index
    end
  end  
end
