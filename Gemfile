source 'https://rubygems.org'

# App
gem 'rails', '3.2.13'
gem 'mysql2'
gem 'figaro'
gem 'devise'
gem 'rabl'
gem 'ledermann-rails-settings', :require => 'rails-settings'
gem 'paperclip', '~> 3.4.2'
gem 'nokogiri'

# Admin
gem 'activeadmin'
gem 'meta_search', '>= 1.1.0.pre'

# Backbone
gem 'backbone-on-rails', '>= 1.0.0'

# Rack Middleware
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'rack-p3p'

# Assets
gem 'gon'
gem 'eco'
gem 'haml-rails'
gem 'jquery-rails'

# Jobs
gem 'sidekiq'
gem 'sinatra', :require => nil

gem "js-routes"

# Amazon
gem 'aws-sdk'
gem 'wicked'
# Openfire
gem 'openfire_api', :git => 'git://github.com/paulasmuth/openfire_api.git'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'hamlbars', '~> 2.0'
  gem 'handlebars_assets'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'rspec_junit_formatter'
  gem 'guard-rspec'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers'
  gem 'mocha', :require => false
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'simplecov', :require => false
  gem 'email_spec'
end

group :development do
  gem 'quiet_assets'
  gem 'awesome_print'
  gem 'hirb'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request', '0.2.1'
  gem 'letter_opener'
  gem 'thin'
end