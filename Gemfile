source 'https://rubygems.org'

gem 'rails', '~> 8.1.1'
gem 'rake', '~> 12.0'
gem 'sprockets-rails'
# Use postgres
gem 'pg', '~> 1.0'
# Fast loading
# gem 'bootsnap', '~> 1.3'
# Active Record extensions
gem 'active_record_union', '~> 1.4'
gem 'ancestry'
# SASS for stylesheets
gem 'sass-rails', '~> 6'
# Compress JavaScript assets
gem 'terser', '~> 1.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5'
# Easy styling
gem 'bootstrap', '~> 4.5.0'
# Easy bootstrap forms
gem 'bootstrap_form', '~> 4.5'
# Inline svgs
gem 'inline_svg'
# Bootstrap markdown editor
gem 'font-awesome-rails'
gem 'pagedown-bootstrap-rails'
# Nested Forms
gem 'cocoon'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Steam Login
gem 'omniauth', '~> 2'
gem 'omniauth-discord'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-steam'
# Authentication
gem 'devise'
# Use haml for templating
gem 'haml', '~> 6'
# Forum Pages
gem 'will_paginate', '~> 3.3.0'
gem 'will_paginate-bootstrap4'
# Forum markdown formatting
gem 'redcarpet'
# File Uploads
gem 'carrierwave'
gem 'mini_magick'
# API Serialization
gem 'active_model_serializers', '~> 0.10.0'
# Simplified counter caches
gem 'counter_culture', '~> 2.0'
# Tournament systems
gem 'tournament-system', '~> 2.0'
# Backwards compatibility with ruby 2
gem 'scanf'
# Ruby 4.0 compatibility - gems removed from stdlib
gem 'cgi'
gem 'ostruct'

group :production do
  gem 'puma', '~> 6.0'
end

group :test do
  # Use rspec for tests
  gem 'rspec-rails', '~> 6'

  # Extra functionality for rspec-rails
  gem 'rails-controller-testing'

  # Parallelize tests
  gem 'parallel_tests'

  # Test coverage
  gem 'simplecov'

  # Use for validation testing
  gem 'shoulda-matchers'

  # Clean db for tests
  gem 'database_cleaner'

  # Easy database manipulation
  gem 'factory_bot_rails', '~> 6'

  # Web feature testing
  gem 'capybara'

  # Keep codebase clean
  gem 'haml_lint', require: false
  gem 'rails_best_practices', require: false
  gem 'reek', '~> 6', require: false
  gem 'rubocop', '~> 1.82', require: false
  gem 'rubocop-rails', '~> 2.34', require: false

  gem 'codecov', require: false
end

group :development do
  # Test emails
  gem 'letter_opener'

  # Profilers
  gem 'bullet'

  # Faster development
  gem 'spring', require: false

  # Tool for database maintenance
  gem 'active_record_doctor', require: false

  # Development scripts
  gem 'capistrano', '~> 3.1', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  # Needed to make capistrano function
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0', require: false
  gem 'ed25519', '>= 1.2', '< 2.0', require: false
end
