require 'rvm/capistrano'
set :user, "ubuntu"
set :deploy_to, "/apps/#{app}"
set :rvm_ruby_string, 'ruby-1.9.2-p180@Bitflow-prod'
set :rvm_type, :user


role :web, "ec2-46-137-131-15.eu-west-1.compute.amazonaws.com"                          # Your HTTP server, Apache/etc
role :app, "ec2-46-137-131-15.eu-west-1.compute.amazonaws.com"                          # This may be the same as your `Web` server
role :db,  "ec2-46-137-131-15.eu-west-1.compute.amazonaws.com", :primary => true # This is where Rails migrations will run

