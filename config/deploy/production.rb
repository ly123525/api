# -*- encoding : utf-8 -*-
set :stage, :production
set :branch, 'master'
set :rvm_type, :user
set :rvm_ruby_version, '2.1.0'

#for resque 
role :resque_worker, ["182.92.79.93", "59.110.48.115"]

set :workers, { "background_worker" => 1 }

server '182.92.79.93', user: 'seairy', roles: %w{web app db}, port: 22000, primary: true
server '59.110.48.115', user: 'deployer', roles: %w{web app db}, port: 22000, primary: true

set :deploy_to, "/srv/www/ApiService"
set :rails_env, :production

after "deploy", "deploy:passenger:restart"
after "deploy", "deploy:daemon:restart"

after "deploy", "resque:restart"
