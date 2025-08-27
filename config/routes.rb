Rails.application.routes.draw do
  get "home/index"
  # config/routes.rb
  root 'home#index'

  # Rotte per le viste HTML (Frontend)
  # Queste rotte sono per le pagine del tuo sito che restituiscono HTML
  get 'home/sedi', to: 'home#sedi'
  get 'home/mappa', to: 'home#mappa'
  get 'home/profilo', to: 'home#profilo'
  get 'home/registrazione', to: 'home#registrazione'
  get 'home/meteo', to: 'home#meteo'
  
  # Rotte personalizzate che restituiscono HTML
  get 'percorsi', to: 'percorsi#index'
  get 'news', to: 'news#index'
  get 'supporto', to: 'supporto#index'
  get 'profilo', to: 'profilo#index'
  get 'login', to: 'auth#login'
  get 'registration', to: 'users#new'

  # Rotte API per la gestione delle risorse RESTful
  # Questa riga gestisce tutte le operazioni CRUD per il modello Sede.
  # La rotta GET /sedi per 'index' è inclusa qui.

  resources :sedi, only: [:index, :show, :create, :update, :destroy]


  # Rotte aggiuntive che non rientrano in una risorsa specifica
  post 'login', to: 'sessions#create'
  get 'forgot_password', to: 'passwords#new'
  get 'home/weather', to: 'weather#show'
  get "up" => "rails/health#show", as: :rails_health_check
end
