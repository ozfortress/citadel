# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)
Rails.application.load_tasks

# Load test tasks
begin
  require 'rspec/core/rake_task'
  require 'parallel_tests/tasks'
  require 'haml_lint/rake_task'
  require 'rubocop/rake_task'
  require 'reek/rake/task'

  RSpec::Core::RakeTask.new(:rspec)
  HamlLint::RakeTask.new
  RuboCop::RakeTask.new
  Reek::Rake::Task.new

  task :rbp do
    require 'rails_best_practices'

    app_root = Rake.application.original_dir
    analyzer = RailsBestPractices::Analyzer.new(app_root)
    analyzer.analyze
    analyzer.output
  end

  Rake::Task['test'].clear # Rails puts minitest on the test task automatically'
  task lint: %w[rubocop haml_lint rbp reek]
  task test: %w[parallel:spec lint]
  task default: [:test]
rescue LoadError
  puts 'Test tasks not available'
end

task :log do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
