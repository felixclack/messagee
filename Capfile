load 'deploy' if respond_to?(:namespace) # cap2 differentiator

default_run_options[:pty] = true
ssh_options[:keys] = "~/.ssh/brightbox-key"

# be sure to change these
set :user, 'felixclack'
set :domain, 'messagee.co.uk'
set :application, 'messagee'

# the rest should be good
set :repository,  "git@github.com:kid80/#{application}.git" 
set :deploy_to, "/home/#{user}/#{domain}"
set :deploy_via, :remote_cache
set :scm, 'git'
set :scm_passphrase, "saffron"
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :use_sudo, false

server domain, :app, :web

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
end

task :ssh do
  system "ssh -i ~/.ssh/brightbox-key #{user}@#{domain}"
end