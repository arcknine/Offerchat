ssh_options[:keys] = ["~/.ssh/tokyo_offerchat.pem"]

set :rvm_ruby_string, '1.9.3@offerchat'
set :bundle_cmd, "/home/ubuntu/.rvm/gems/ruby-1.9.3-p429@global/bin/bundle"

set :user, "ubuntu"
set :use_sudo, false
set :branch, "staging"
set :rails_env, "staging"

server "54.249.110.86", :app, :web, :db, :primary => true
