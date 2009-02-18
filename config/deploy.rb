set :application, "bis.3dbyggeri.dk"

set :scm, :git
set :repository, "git@github.com:3dbyggeri/bis.git"
set :branch, "master"
set :deploy_via, :remote_cache # faster deployment - don't pull a new repository for each deploy

set :deploy_to, "/usr/local/www/rails/#{application}"
set :user, "cap" # defaults to the currently logged in user
role :app, "web01.liisberg.net"
role :web, "web01.liisberg.net"
role :db,  "web01.liisberg.net", :primary => true

set :app_url, "bis.3dbyggeri.dk"

namespace :deploy do
  namespace :mongrel do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} the mongrel appserver"
      task t, :roles => :app do
        sudo "/usr/local/etc/rc.d/mongrel_cluster #{t.to_s} #{app_url}"
      end
    end
  end

  desc "Custom restart task for mongrel cluster"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.mongrel.restart
  end

  desc "Custom start task for mongrel cluster"
  task :start, :roles => :app do
    deploy.mongrel.start
  end

  desc "Custom stop task for mongrel cluster"
  task :stop, :roles => :app do
    deploy.mongrel.stop
  end
end

# Specific for dynamically adding the production database password to the database.yml file upon deploy 
namespace :deploy do
  after "deploy:update_code", "deploy:config_database"
  
  desc "After updating code we need to populate a new database.yml"
  task :config_database, :roles => :app do
    require "yaml"
    set :production_database_password, proc { Capistrano::CLI.password_prompt("Production database remote password: ") }

    buffer = YAML::load_file('config/database.yml')
    # get ride of uneeded configurations
    buffer.delete('test')
    buffer.delete('development')

    # Populate production element
    buffer['production']['password'] = production_database_password

    put YAML::dump(buffer), "#{release_path}/config/database.yml", :mode => 0664
  end
end
