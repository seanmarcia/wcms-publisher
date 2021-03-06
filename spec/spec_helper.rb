# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'pundit/rspec'
require 'sidekiq/testing'
# require 'rspec/autorun'

Mongoid.load!('spec/config/mongoid.yml', :test)

# Load factories from buweb
BuwebContentModels.load_factories
FactoryGirl.reload

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/services/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/support/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/helpers/*.rb")].each { |f| require f }

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods
  config.include Mongoid::Matchers, type: :model

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Rspec 3 no longer automatically infers an example group's spec type from the file location.
  #  This turns the behavior back on.
  # Otherwise you will need to manually label spec types
  config.infer_spec_type_from_file_location!

  config.before(:context, type: :feature) do
    Sidekiq::Testing.inline!
  end

  config.before(:context, type: :unit) do
    Sidekiq::Testing.fake!
  end

  config.before(:each) do
    Mongoid.purge!
    # FactoryGirl.lint

    response = OpenStruct.new(code: 200)
    CarrierwaveRoz::Client.any_instance.stub(upload: response, delete: response)
  end

  config.after(:all) do
    path = "#{Rails.root}/public"
    FileUtils.rm_rf(Dir["#{path}/uploads/[^.]*"])
  end
end
