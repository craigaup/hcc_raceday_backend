. ./server_variables.sh
bundle install
RAILS_ENV=$HCC_ENVIRONMENT rails db:migrate
