require 'database_cleaner/active_record'

DatabaseCleaner.allow_remote_database_url = true

DatabaseCleaner.strategy = :transaction  # default per scenari non-JS

Before('@javascript') do
  DatabaseCleaner.strategy = :truncation  # obbligatorio con Selenium
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end