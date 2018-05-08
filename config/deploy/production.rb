# -*- encoding : utf-8 -*-
set :stage, :production
set :branch, 'master'
set :rvm_type, :user
set :rvm_ruby_version, '2.3.3'
set :deploy_user, 'master'

server '39.105.15.247', user: 'master', roles: %w{web app db}, port: 22, primary: true

set :deploy_to, "/srv/www/api"
