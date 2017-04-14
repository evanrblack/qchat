lock '3.8.0'

set :application, 'qchat'
set :repo_url, 'git@github.com:evanrblack/qchat'
set :user, 'deploy'
set :use_sudo, false
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets'
append :linked_files, '.env.production'
# set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }

# Deployment
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

namespace :deploy do
  desc "Make sure local git is in sync with remote"
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc "For initial deployment"
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc "Restart the application"
  task :restart do
    on roles :app, in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  before :starting,     'dotenv:upload'
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# Thin
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_threads, [4, 16]
set :puma_workers, 0

namespace :thin do
  desc "Create Directories for Puma Pids and Socket"
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

  desc 'Output contents of .env.production to server'
  task :output do
    on roles(:app) do
      execute :cat, "#{shared_path}/.env.production"
    end
  end
end
