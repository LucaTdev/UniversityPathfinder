Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*' # In produzione, specifica i domini specifici
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        credentials: false
    end
  end