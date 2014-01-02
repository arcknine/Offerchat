ssh_options[:keys] = ["~/.ssh/offerchat.pem"]

set :rvm_ruby_string, '1.9.3@offerchat'
set :bundle_cmd, "/home/ubuntu/.rvm/gems/ruby-1.9.3-p484@global/bin/bundle"

set :user, "ubuntu"
set :use_sudo, false
set :branch, "master"
set :rails_env, "production"

server "54.211.168.91", :app, :web, :db, :primary => true
