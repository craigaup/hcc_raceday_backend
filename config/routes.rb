Rails.application.routes.draw do
  namespace :api do
    namespace :v2017 do
      get 'data/getCheckpointInfo' => 'data@getCheckpointInfo'
      get 'data/getFirstCanoeNumber' => 'data@getFirstCanoeNumber'
      get 'data/getLastCanoeNumber' => 'data@getLastCanoeNumber'
      get 'data/getCanoeStatusInfo' => 'data@getCheckpointInfo'
      post 'checkpoint/sendCanoe' => 'checkpoint#sendCanoe'
      post 'checkpoint/sendMessage' => 'checkpoint#sendMessage'
      get 'checkpoint/getAllHistory' => 'checkpoint#getAllHistory'
      post 'session/login' => 'session#login'
      get 'session/logout' => 'session#logout'
    end
  end

  # root :to => 'sessions#login'
  # get 'login' => 'sessions#login', as: 'login'
  # post 'login' => 'sessions#login_attempt', as: nil
  # get 'logout' => 'sessions#logout', as: 'logout'
  # get 'home' => 'sessions#home', as: 'home'
  # resources :crafts
  # resources :distances
  # resources :data
  # resources :messages
  # resources :raceadmins
  # resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
