require 'bundler/capistrano'
require 'capistrano_colors'
require 'rvm/capistrano'
require 'capistrano/ext/multistage'
require 'sidekiq/capistrano'

# Basic
set :stages, %w(staging production)
set :application, "Offerchat"
set :repository,  "set your repository location here"
set :keep_releases, 5

# SSH Options
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Deploy Config
set :deploy_to, "/home/ubuntu/apps/offerchat"
set :deploy_via, :remote_cache

set :scm, :git
set :repository, "git@bitbucket.org:offerchat/dashboard.git"

# Sidekiq
set :sidekiq_cmd, "bundle exec sidekiq -q mailer -q default -c 100"
set :sidekiqctl_cmd, "bundle exec sidekiqctl"
set :sidekiq_timeout, 10
set :sidekiq_role, :app
set :sidekiq_pid, "#{current_path}/tmp/pids/sidekiq.pid"
set :sidekiq_processes, 1

# DB Config
after 'deploy:finalize_update', 'db:update_config'
namespace :db do
  task :update_config do
    run "cp -f #{release_path}/config/database.yml.deploy #{release_path}/config/database.yml"
  end
end

# Run migrations
after  'deploy:update_code', 'deploy:migrate'
namespace :deploy do
  after 'deploy:create_symlink', 'deploy:pictures:symlink'

  namespace :pictures do
    desc "Link images from shared to common"
    task :symlink do
      run "cd #{current_path}/public; rm -rf system; ln -s #{shared_path}/system ."
    end
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# Cleanup
after 'deploy:restart', 'deploy:cleanup'
