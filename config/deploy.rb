
set :application, "passenger_blog"
set :user, "azureuser"

 
# Bundler integration (bundle install)
# http://gembundler.com/deploying.html
require "bundler/capistrano"
 
set :deploy_to, "/var/www/#{application}"
set :use_sudo, false
 
# Must be set for the password prompt from git to work
# http://help.github.com/deploy-with-capistrano/
default_run_options[:pty] = true 
set :scm, :git
set :repository, "https://github.com/waynelovely/passenger_blog.git"
set :branch, "master"
set :use_sudo, true


 
server "wtl-web2.cloudapp.net", :web, :app, :db, primary: true

ssh_options[:forward_agent] = true
ssh_options[:port] = 22



 
# http://modrails.com/documentation/Users%20guide%20Nginx.html#capistrano
namespace :deploy do
  desc "Start server"
  task :start, :roles => :app do
    run "#{try_sudo} touch #{File.join(release_path,'tmp','restart.txt')}"
  end
  
  # not supported by Passenger server
  task :stop, :roles => :app do
  end
  
  desc "Restart server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(release_path,'tmp','restart.txt')}"
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    #run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end
  
  desc "Execute migrations"
  task :migrate, :roles => :db do
    run "bundle exec rake db:migrate"
  end
end
 
after 'deploy:update_code', 'deploy:symlink_shared'
