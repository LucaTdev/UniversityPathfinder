Rails.application.routes.draw do
  get "home/index"

  root 'home#index'
  
  get 'sedi', to: 'sedi#index'
  get 'percorsi', to: 'percorsi#index'
  get 'news', to: 'news#index'
  get 'supporto', to: 'supporto#index'
  get 'profilo', to: 'profilo#index'
  get 'login', to: 'auth#login'
  
  get "home/profilo"

  get "home/sedi"

  get "home/mappa"
  #wheater
  get 'home/weather', to: 'weather#show'


  get "home/login"
  post 'login', to: 'sessions#create'
  get 'forgot_password', to: 'passwords#new'
  get 'registration', to: 'users#new'

  get 'home/registrazione'

  get "home/meteo"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
