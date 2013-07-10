set :rvm_ruby_string, '1.9.3@offerchat'
set :bundle_cmd, "/home/ubuntu/.rvm/gems/ruby-1.9.3-p429@global/bin/bundle"

set :user, "ubuntu"
set :use_sudo, false
set :branch, "staging"
set :rails_env, "staging"

server "184.73.50.116", :app, :web, :db, :primary => true
