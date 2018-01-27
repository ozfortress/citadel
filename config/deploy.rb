# config valid only for current version of Capistrano
lock '3.10.1'

set :application, 'citadel'
set :rvm_ruby_string, 'ruby-2.5.0'

# git settings
set :repo_url, 'git@github.com:ozfortress/citadel.git'
set :branch, :ozfortress

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/citadel'

set :rails_env, 'production'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Make sure password prompts show locally
set :pty, true

# Files and folders to keep between deployments
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/news.yml')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp', 'vendor/bundle', 'public/uploads')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
