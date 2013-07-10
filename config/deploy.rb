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
ssh_options[:keys] = ["~/.ssh/offerchat.pem"]

# Deploy Config
set :deploy_to, "/home/ubuntu/apps/offerchat"
set :deploy_via, :remote_cache

set :scm, :git
set :repository, "git@bitbucket.org:offerchat/dashboard.git"

# Run migrations
after  'deploy:update_code', 'deploy:migrate'

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  after 'deploy:create_symlink', 'deploy:pictures:symlink'
  after 'deploy:pictures:symlink', 'deploy:setup_db'

  namespace :pictures do
    desc "Link images from shared to common"
    task :symlink do
      run "cd #{current_path}/public; rm -rf system; ln -s #{shared_path}/system ."
    end
  end

  task :setup_db do
    run "cp #{current_path}/config/database.yml.deploy #{current_path}/config/database.yml"
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

# Cleanup
after 'deploy:restart', 'deploy:cleanup'
