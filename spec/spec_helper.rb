# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'
SimpleCov.start do
  add_filter "/spec"
  add_filter "/config"
  add_filter "/app/workers"
  add_filter "/spec/mailers"
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'sidekiq/testing'
require "paperclip/matchers"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :mocha

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.add_setting(:seed_tables)
  config.seed_tables = %w( plans )

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, except: config.seed_tables)
  end

  config.around(:each) do |ex|
    if ex.metadata[:no_transactions]
      DatabaseCleaner.strategy = :truncation, { except: config.seed_tables }
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.start
    ex.run
    DatabaseCleaner.clean
  end

  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller

  config.include Paperclip::Shoulda::Matchers

  config.include RSpec::Rails::RequestExampleGroup, type: :request, example_group: { file_path: /spec\/api/ }
end

RSpec::Sidekiq.configure do |config|
  # Clears all job queues before each example
  config.clear_all_enqueued_jobs = false # default => true
end
