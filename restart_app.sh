. ./server_variables.sh

bundle install --deployment
RAILS_ENV=$HCC_ENVIRONMENT rails assets:precompile 
RAILS_ENV=$HCC_ENVIRONMENT rails db:migrate

passenger-config restart-app $(pwd)

