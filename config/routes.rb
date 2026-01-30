Rails.application.routes.draw do  
  
  get "home/index"
  root 'home#index'

  get 'percorsi', to: 'percorsi#index'
  get 'news', to: 'news#index'
  get 'home/profilo'

  get "home/sedi"

  get "home/mappa"
  #wheater
  get 'home/weather', to: 'weather#show'

  resources :sedi, only: [:index, :show, :create, :update, :destroy]
  #Per ottenere le info di profilo dal database
  resources :users do
    member do
      get:profile
      patch :update_profile
    end
  end
  # Rotta per il profilo dell'utente corrente
  get 'profile', to: 'users#profile'
  get 'profile/edit', to: 'users#edit_profile'
  patch 'profile', to: 'users#update_profile'

  get "sessions/new"
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout #delete 'logout', to: 'sessions#destroy'

  get 'users/new'
  get 'forgot_password', to: 'passwords#new'
  get 'registration', to: 'users#new'
  post 'registration', to: 'users#create'


#LUCA
  #Path 
  get 'admin/faqs', to: 'faqs#admin', as: 'admin_faqs'
  get 'user/faqs', to: 'faqs#user', as: 'user_faqs'
  get 'visitors/faqs', to: 'faqs#visitor', as: 'visitor_faqs'

  #FAQ
  resources :faqs, only: [:create, :update, :destroy]



  get "home/meteo", to: "home#meteo"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :percorsi, only: [:create]


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end