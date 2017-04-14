# config valid only for current version of Capistrano
lock '3.8.0'

# Basics
set :application, 'qchat'
set :repo_url, 'git@github.com:evanrblack/qchat.git'
set :user, 'deploy'
set :use_sudo, false
append :linked_dirs, 'log', 'tmp/pids', 'tmp/sockets'
append :linked_files, '.env.production'
set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }

# Deployment
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

before 'deploy:starting', 'dotenv:upload'
after 'deploy:finishing', 'thin:start'

namespace :deploy do
  desc "Set RACK_ENV to production"
  task :set_env do
    on roles(:app) do
      execute 'RACK_ENV=production'
    end
  end

  before :starting, :set_env
end

namespace :thin do
  desc "Create directories for Thin pids and sockets"
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

# Dotenv
namespace :dotenv do
  desc 'Upload .env.production to server'
  task :upload do
    on roles(:app) do
      upload! '.env.production', "#{shared_path}/.env.production"
    end
  end

  desc 'Output contents of .env.production from server'
  task :output do
    on roles(:app) do
      execute :cat, "#{shared_path}/.env.production"
    end
  end
end
