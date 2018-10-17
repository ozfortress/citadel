source 'https://rubygems.org'

gem 'rake', '~> 12.0'
gem 'rails', '= 5.2.1'
# Use postgres
gem 'pg', '~> 1.0'
# Fast loading
gem 'bootsnap', '~> 1.3'
# Active Record extensions
gem 'active_record_union', '~> 1.3'
gem 'ancestry'
# SASS for stylesheets
gem 'sass-rails', '~> 5.0'
# Compress JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.0'
# Easy styling
gem 'bootstrap-sass', '~> 3.3.6'
# Bootstrap datetime picker
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'
# Easy bootstrap forms
gem 'bootstrap_form'
# Bootstrap markdown editor
gem 'pagedown-bootstrap-rails'
gem 'font-awesome-rails'
# Nested Forms
gem 'cocoon'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Steam Login
# TODO: Remove git dependency once upstream is updated.
gem 'omniauth-steam'
# Authentication
gem 'devise'
# Use hamlit for ~fast templating
gem 'hamlit'
# Forum Pages
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap'
# Forum markdown formatting
gem 'redcarpet'
# File Uploads
gem 'carrierwave'
gem 'mini_magick'
# Tracking and analytics
gem 'ahoy_matey', '~> 1.6'
# API Serialization
gem 'active_model_serializers', '~> 0.10.0'
# Tournament systems
gem 'tournament-system', '~> 2.1.0'

group :test do
  # Use rspec for tests
  gem 'rspec-rails', '~> 3.8'

  # Parallelize tests
  gem 'parallel_tests'

  # Test coverage
  gem 'simplecov'

  # Use for validation testing
  gem 'shoulda-matchers'

  # Clean db for tests
  gem 'database_cleaner'

  # Easy database manipulation
  gem 'factory_bot_rails', '~> 4'

  # Web feature testing
  gem 'capybara'

  # Keep codebase clean
  gem 'rubocop', '~> 0.58', require: false
  gem 'haml_lint', require: false
  gem 'rails_best_practices', require: false
  gem 'reek', '~> 5', require: false

  # Coveralls
  gem 'coveralls'
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
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-passenger', require: false
end
