# -*- encoding : utf-8 -*-
require 'capistrano'

set :application, 'api'

set :scm, :git
set :repo_url, 'git@git.coding.net:Dark_L/api.git'
set :git_strategy, Capistrano::Git::SubmoduleStrategy
set :git_keep_meta, true

set :keep_releases, 5

set :linked_files, %w{config/database.yml config/newrelic.yml}
set :linked_dirs, %w{bin log tmp}

set :use_sudo, false

namespace :deploy do
  namespace :passenger do
    desc "Restart passenger server"
    task :restart do
      on roles(:app) do
        within current_path do
          execute :touch, 'tmp/restart.txt'
        end
      end
    end
  end
end
after "deploy", "deploy:passenger:restart"
