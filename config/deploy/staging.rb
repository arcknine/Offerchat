ssh_options[:keys] = ["~/.ssh/offerchat.pem"]

set :rvm_ruby_string, '1.9.3@offerchat'
set :bundle_cmd, "/home/ubuntu/.rvm/gems/ruby-1.9.3-p484@global/bin/bundle"

set :user, "ubuntu"
set :use_sudo, false
set :branch, "staging"
set :rails_env, "staging"

server "23.20.21.172", :app, :web, :db, :primary => true
