require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, "ree-1.8.7@mphoriaapi"

require 'bundler/capistrano'

set :application, "BitFlow"
set :repository,  "git@github.com:pjc/BitFlow.git"
set :scm, :git
set :use_sudo, false
set :branch, 'master'
set :notification_address, "sreeix@gmail.com"
set :deploy_to, "/apps/#{application}"

set :stages, %w(staging production)
set :default_stage, 'staging'
set :deploy_via, :remote_cache
set :rails_env, 'production'
set :normalize_asset_timestamps, false  # does not normalize the javascript/stylesheets etc.

set :scm, :git

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end