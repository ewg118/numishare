set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "coins"
set :repository,  "git://github.com/waynegraham/numishare.git"
set :scn, :git
set :branch, "feature/uva_deployment"

set :user, 'sds-deployer'
set :run_method, :run

set :deploy_to, "/usr/local/projects/#{application}"
set :deploy_via, :remote_cache

set :normalize_asset_timestamps, false

# if you want to clean up old releases on each deploy uncomment this:
after "deploy", "solr:index"
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  desc 'Make the links'
  task :link, :roles => :app, :except => { :no_release => true } do
    web_root = "#{current_path}/www"
    run "mkdir -p #{web_root}"
    run "cd #{web_root} && ln -snf #{current_path}/cocoon/css/style.css"
    run "cd #{web_root} && ln -snf #{current_path}/cocoon/css/themes"
    run "cd #{web_root} && ln -snf #{current_path}/cocoon/css/jquery.fancybox-1.3.4.css"
    run "cd #{web_root} && ln -snf #{current_path}/cocoon/css/jquery.multiselect.css"
    run "cd #{web_root} && ln -snf #{current_path}/cocoon/css/jquery-ui-1.8.10.custom.css"
    run "cd #{web_root} && ln -snf #{current_path}/cocoon/images"
    run "cd #{web_root} && ln -snf #{current_path}/cocoon/javascript"
    run "cd #{web_root}/images && ln -snf #{shared_path}/coins"
  end
end

namespace :solr do
  desc 'Runs the indexer/generate_index.sh script'
  task :index, :roles => :app, :except => {:no_release => true} do
    run "cd #{current_path}/indexer && ./generate_index.sh"
  end
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart do; end
end
