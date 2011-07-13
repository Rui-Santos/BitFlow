$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require "rvm/capistrano"                  # Load RVM's capistrano plugin.


set :application, "BitFlow"
set :repository,  "git@github.com:pjc/BitFlow.git"
set :scm, :git
set :use_sudo, false
set :branch, 'master'
set :notification_address, "sreeix@gmail.com"
set :deploy_to, "/apps/#{application}"
set :rvm_ruby_string, 'ruby-1.9.2-p180@BitFlow'
set :rvm_type, :user

set :stages, %w(staging production)
set :default_stage, 'staging'

set :deploy_via, :remote_cache
set :rails_env, 'production'
set :normalize_asset_timestamps, false  # does not normalize the javascript/stylesheets etc.

before 'deploy:migrate', 'bitflow:copy_config'
after "deploy:migrate" , "bitflow:restart"


namespace :bitflow do
  desc "copies db configs to the right place"
  task :copy_config do
    run "cp -f #{release_path}/config/deploy/#{stage}/database.yml #{release_path}/config/database.yml"
  end
  
  desc "restarts unicorn"
  task :restart do
    run "kill -QUIT `cat #{deploy_to}/shared/pids/unicorn.pid`; true"
    run "cd #{release_path} && bundle exec unicorn -Dc #{release_path}/config/unicorn.rb -E production"
  end
end
namespace :deploy do
  task :restart do
    #noop
  end
end
