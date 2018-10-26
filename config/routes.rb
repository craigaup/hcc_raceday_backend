Rails.application.routes.draw do
  #resources :lora_device_mappings
  namespace :api do
    namespace :v2018 do
      get 'lora/send', to: 'lora#sendData'
      post 'lora/send', to: 'lora#sendData'
    end
  end

  get 'checkpoint/overview'

  get 'checkpoint/info/:checkpoint', to: 'checkpoint#info', \
    as: 'checkpoint_info'

  namespace :api do
    namespace :v2017 do
      get 'canoes/locations', to: 'canoes#locations'
      get 'canoes/locations/:show_checkpoints/:canoes/:uniq', \
        to: 'canoes#locations'
      get 'canoes/finish-info', to: 'canoes#finish_info'
      get 'status/types', to: 'status#types'
      post 'status/non-starters/complete/set', to: 'status#setComplete'
      get 'status/non-starters/complete', to: 'status#getComplete'
      get 'canoes/:number/info', to: 'canoes#info'
      get 'canoes/first', to: 'canoes#first'
      post 'canoes/last/:number/set', to: 'canoes#set_last'
      get 'canoes/last', to: 'canoes#last'
      post 'canoes/:number/:status/:checkpoint/:date_time', to: 'canoes#add'
      get 'canoes/:number/history', to: 'canoes#history'
      get 'canoes/:number/history/:interval', to: 'canoes#history'
      get 'canoes/:number/status', to: 'canoes#status'
      get 'canoes/field/:interval', to: 'canoes#field'
      get 'canoes/field', to: 'canoes#field'
      get 'canoes/withdrawals', to: 'canoes#withdrawal_list'
      get 'canoes/nonstarters', to: 'canoes#nonstarter_list'
      get 'canoes/:number/status', to: 'canoes#status'
      post 'canoes/send', to: 'canoes#sendData'
      post 'checkpoints/sendCanoe', to: 'checkpoints#sendCanoe'
      get 'checkpoints/:checkpoint/status', to: 'checkpoints#status'
      get 'checkpoints/:checkpoint/status/:interval', to: 'checkpoints#status'
      get 'checkpoints/info', to: 'checkpoints#info'
      post 'session/login', to: 'session#login'
      get 'session/logout', to: 'session#logout'
    end
  end

  root :to => 'checkpoint#overview'
  get 'login' => 'sessions#login', as: 'login'
  post 'login' => 'sessions#login_attempt', as: nil
  get 'logout' => 'sessions#logout', as: 'logout'
  get 'home' => 'checkpoint#overview', as: 'home'
  get 'change_password' => 'sessions#change_password', as: 'change_password'
  post 'change_password' => 'sessions#change_password_attempt', as: nil
  get '/canoe_locations', to: 'crafts#location', as: 'canoe_locations'
  # resources :crafts
  # resources :distances
  # resources :data
  # resources :messages
  # resources :raceadmins
  # resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
