ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

if defined?(ActiveRecord)
  # Avoid automatic schema purge/load on test boot. In this project the test DB
  # is shared enough that the auto-maintenance step produces noisy warnings.
  ActiveRecord.maintain_test_schema = false
end

require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
