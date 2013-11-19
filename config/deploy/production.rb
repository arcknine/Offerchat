ssh_options[:keys] = ["~/.ssh/offerchat.pem"]

set :rvm_ruby_string, '1.9.3@offerchat'
set :bundle_cmd, "/home/ubuntu/.rvm/gems/ruby-1.9.3-p429@global/bin/bundle"

set :user, "ubuntu"
set :use_sudo, false
set :branch, "master"
set :rails_env, "production"

role :app, "54.211.184.139", "54.211.183.89", "54.211.187.204"
role :web, "54.211.184.139", "54.211.183.89", "54.211.187.204"
role :db, "54.211.184.139", :primary => true
