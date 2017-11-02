require 'dotenv'
ENV['RACK_ENV'] ||= 'development'
Dotenv.load(".env.#{ENV['RACK_ENV']}")

namespace :db do
  require 'sequel'
  Sequel.extension :migration
  DB = Sequel.connect(ENV['DATABASE_URL'])

  desc "Migrate the database"
  task :migrate do
    puts "Migrating database..."
    Sequel::Migrator.run(DB, 'db/migrate')
  end

  desc "Roll back the database"
  task :rollback do
    puts "Rolling back database..."
    Sequel::Migrator.run(DB, 'db/migrate', relative: -1)
  end
end

require 'resque/tasks'
task 'resque:setup' => :environment

task :environment do
  require './app'
end
