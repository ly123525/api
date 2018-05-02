# -*- encoding : utf-8 -*-
set :stage, :staging
set :branch, 'staging'
set :rvm_type, :user
set :rvm_ruby_version, '2.3.3'
set :deploy_user, 'master'

server '47.93.35.120', user: 'master', roles: %w{web app db}, port: 22, primary: true

set :deploy_to, "/srv/www/api"
