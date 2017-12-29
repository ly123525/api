# -*- encoding : utf-8 -*-
set :stage, :staging
set :branch, 'development'
set :rvm_type, :user
set :rvm_ruby_version, '2.3.3'
set :deploy_user, 'master'

#for resque 
role :resque_worker, "182.92.188.221"
set :workers, { "background_worker" => 1 }

server '182.92.188.221', user: 'master', roles: %w{web app db}, primary: true

set :default_env, { 
  'cap_test' => 'value1',
}


set :deploy_to, "/srv/www/ApiService"

after "deploy", "deploy:passenger:restart"
after "deploy", "deploy:daemon:restart"
after "deploy", "resque:restart"

set :bundle_without, ['test']

