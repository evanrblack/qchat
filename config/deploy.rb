# config valid only for current version of Capistrano
lock '3.8.0'

require 'pry'

# Basics
set :application, 'qchat'
set :repo_url, 'git@github.com:evanrblack/qchat.git'
set :user, 'deploy'
set :use_sudo, false
append :linked_dirs, 'log', 'tmp/pids', 'tmp/sockets'
append :linked_files, '.env.production'
set :ssh_options, { forward_agent: true, user: fetch(:user), 
                    keys: %w(~/.ssh/id_rsa.pub) }

# Deployment
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

before 'deploy:started', 'dotenv:upload'
before 'deploy:started', 'deploy:make_dirs'
#after 'deploy:updated', 'db:migrate'
after 'deploy:finished', 'thin:smart_restart'

namespace :deploy do
  desc "Create directories for pids and sockets"
  task :make_dirs do
    on roles(:app) do
      execute :mkdir, "#{shared_path}/tmp/sockets -p"
      execute :mkdir, "#{shared_path}/tmp/pids -p"
    end
  end
end

namespace :thin do
  pid_path = "#{shared_path}/tmp/pids/thin.pid"

  desc "Smartly start thin"
  task :smart_start do
    on roles(:app) do
      invoke 'thin:start' unless test "[ -f #{pid_path} ]"
    end
  end

  desc "Smartly stop thin"
  task :smart_stop do
    on roles(:app) do
      invoke 'thin:stop' if test "[ -f #{pid_path} ]"
    end
  end

  desc "Smartly restart thin"
  task :smart_restart do
    on roles(:app) do
      if test "[ -f #{pid_path} ]"
        invoke 'thin:restart'
      else
        invoke 'thin:start'
      end
    end
  end
end

# Database
namespace :db do
  desc "Migrate database"
  task :migrate do
    on roles(:app) do
      execute :rake, 'db:migrate'
    end
  end

  desc "Roll back database"
  task :rollback
  on roles(:app) do
    execute :rake, 'db:rollback'
  end
end

# Dotenv
namespace :dotenv do
  desc "Upload .env.production to server"
  task :upload do
    on roles(:app) do
      upload! '.env.production', "#{shared_path}/.env.production"
    end
  end

  desc "Output contents of .env.production from server"
  task :output do
    on roles(:app) do
      execute :cat, "#{shared_path}/.env.production"
    end
  end
end

