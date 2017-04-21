require 'dotenv'
ENV['RACK_ENV'] ||= 'development'
Dotenv.load(".env.#{ENV['RACK_ENV']}")

namespace :db do
  require 'sequel'
  Sequel.extension :migration
  DB = Sequel.connect(ENV['DB_URL'])

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

namespace :resque do
  MAX_WORKERS = (ENV['MAX_WORKERS'] || 1).to_i
  PID_DIR = 'tmp/pids'

  desc "Stop all Resque workers"
  task :stop_all do
    # Find exisiting pidfiles, send QUIT, remove pidfiles
    Dir["#{PID_DIR}/resque.*.pid"].each do |path|
      pid = File.read(path).strip.to_i
      if pid
        puts "Sending QUIT to Resque worker (PID = #{pid})..."
        `kill -s QUIT #{pid}`
      end
      puts "Deleting pidfile for Resque worker (PID = #{pid})..."
      File.delete(path)
    end
  end

  desc "Start all Resque workers"
  task :start_all do
    # Create new workers
    ENV['QUEUE'] = '*'
    ENV['BACKGROUND'] = 'yes'
    MAX_WORKERS.times do |i|
      ENV['PIDFILE'] = "#{PID_DIR}/resque.#{i}.pid"
      puts "Starting Resque worker #{i}..."
      `bundle exec rake resque:work`
    end
  end

  desc "Restart all Resque workers"
  task :restart_all do
    Rake::Task['resque:stop_all'].invoke
    Rake::Task['resque:start_all'].invoke
  end
end

task :environment do
  require './app'
end

require 'resque/tasks'
task 'resque:setup' => :environment
