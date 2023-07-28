# frozen_string_literal: true

namespace :test do
  desc 'Run tests with the SQLite database'
  task :sqlite do
    # Set an environment variable to change the database configuration
    ENV['DB'] = 'sqlite'
    Rake::Task['test'].invoke
  end

  desc 'Run tests with the Postgres database'
  task :postgres do
    ENV['DB'] = 'postgres'
    Rake::Task['test'].invoke
  end
end
