# -*- encoding : utf-8 -*-
set :stage, :development
set :branch, 'development'
set :rvm_type, :user
set :rvm_ruby_version, '2.3.3'
set :deploy_user, 'master'

# bundle 时候排除 test
set :bundle_without, ['test']
# 开发、静默
set :bundle_flags, '--deployment --quiet'

server '39.106.190.128', user: 'master', roles: %w{web app db}, port: 22, primary: true

set :deploy_to, "/srv/www/api"
