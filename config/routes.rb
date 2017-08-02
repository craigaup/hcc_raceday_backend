Rails.application.routes.draw do
  root :to => 'sessions#login'
  get 'login' => 'sessions#login', as: 'login'
  post 'login' => 'sessions#login_attempt', as: nil
  get 'logout' => 'sessions#logout', as: 'logout'
  get 'home' => 'sessions#home', as: 'home'
  resources :crafts
  resources :distances
  resources :data
  resources :messages
  resources :raceadmins
  # resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
