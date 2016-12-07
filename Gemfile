source 'https://rubygems.org'

gem 'rails', '4.2.5.1'

gem 'analytics-ruby', '~> 2.1', require: 'segment'
gem 'biola_deploy', '~> 0.7'
gem 'biola_frontend_toolkit', '~> 0.5.6'
gem 'biola_wcms_components', '~> 0.24.1'
gem 'biola_web_services', '~> 1.1.2'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'buweb_content_models', '~> 1.39.1'
gem 'coffee-rails', '>= 4.1'
gem 'font-awesome-rails', '~> 4.4'
gem 'httparty', '~> 0.14.0'
gem 'immutable-struct'
gem 'jbuilder', '~> 2.3', '>= 2.3.2'
gem 'jquery-rails', '~> 4.1.0'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'kaminari-bootstrap', '~> 3.0', '>= 3.0.1'
gem 'mongoid', '~> 5.1'
gem 'newrelic_rpm', '~> 3.14'
# There is an error with origin 2.2.1, which is a dependency of mongoid,
# so for now we are locking the version to 2.2.0
# until they release the fix (>= 2.2.3),
# at which point you can remove this gem declaration.
# https://github.com/mongoid/origin/commit/155a0550629e09c3a96984ab6fe14e2d7931e629
gem 'origin', '2.2.0'
gem 'pinglish', '~> 0.2'
gem 'puma', '~> 2.16'
gem 'pundit', '~> 1.1'
gem 'rack-cas', '>= 0.12.0'
gem 'rails_config', '~> 0.4.2'
gem 'react-rails', '~> 1.6.2'
gem 'responders', '~> 2.3.0'
gem 'sass-rails', '>= 5.0.1'
gem 'sidekiq', '~> 3.3.4'
gem 'sidekiq-status', '~> 0.5.1'
gem 'sidekiq-cron', '~> 0.3.1'
# Sidekiq Web UI does not auto-include Sinatra for you, since some people
# don't use the Web UI. So we need to include sinatra here.
gem 'sinatra', require: false
gem 'slim', '>= 2.1'
gem 'turnout', '~> 2.2', '>= 2.2.1'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'better_errors', '~> 2.1', '>= 2.1.1'
end

group :development, :staging, :test do
  gem 'faker', '~> 1.6', '>= 1.6.1'
end

group :development, :test do
  gem 'binding_of_caller', '>= 0.7.2' # Needed for better_errors to work properly
  gem 'factory_girl_rails', '~> 4.5'
  gem 'mongoid-rspec', '~> 3.0'
  gem 'rspec-rails', '~> 3.4', '>= 3.4.1'
  gem 'rspec-core', '>= 3.4.4' # fixes rake deprication error
  gem 'pry', '>= 0.10.3'
end

group :production do
  gem 'sentry-raven', '~> 0.15'
end

group :test do
  gem 'capybara', '~> 2.6', '>= 2.6.2'
end
