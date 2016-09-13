source 'https://rubygems.org'

gem 'rails', '4.2.5.1'

gem 'analytics-ruby', '~> 2.1', :require => "segment"
gem 'biola_deploy', '~> 0.7'
gem 'biola_frontend_toolkit', '~> 0.5.6'
gem 'biola_wcms_components', '~> 0.24.1'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'buweb_content_models', '~> 1.31'
gem 'coffee-rails', '>= 4.1'
gem 'font-awesome-rails', '~> 4.4'
gem 'httparty', '~> 0.14.0'
gem 'immutable-struct'
gem 'jbuilder', '~> 2.3', '>= 2.3.2'
gem 'jquery-rails', '~> 4.1.0'
gem 'kaminari-bootstrap', '~> 3.0', '>= 3.0.1'
gem 'mongoid', '~> 5.1'
gem 'newrelic_rpm', '~> 3.14'
gem 'pinglish', '~> 0.2'
gem 'puma', '~> 2.16'
gem 'pundit', '~> 1.1'
gem 'rack-cas', '>= 0.12.0'
gem 'rails_config', '~> 0.4.2'
gem 'react-rails', '~> 1.6.2'
gem 'sass-rails', '>= 5.0.1'
gem 'slim', '>= 2.1'
gem 'therubyracer', platforms: :ruby
gem 'turnout', '~> 2.2', '>= 2.2.1'
gem 'uglifier', '>= 1.3.0'

group :development do
  gem 'better_errors', '~> 2.1', '>= 2.1.1'
end

group :development, :staging, :test do
  gem 'faker', '~> 1.6', '>= 1.6.1'
end

group :development, :test do
  # # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug'
  # # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'

  # Needed for better_errors to work properly
  gem 'binding_of_caller', '>= 0.7.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '>= 1.6.2'

  gem 'factory_girl_rails', '~> 4.5'
  gem 'mongoid-rspec', '~> 3.0'
  gem 'rspec-rails', '~> 3.4', '>= 3.4.1'
  gem 'pry', '>= 0.10.3'
end

group :production do
  gem 'sentry-raven', '~> 0.15'
end

group :test do
  gem 'capybara', '~> 2.6', '>= 2.6.2'
end
