Sidekiq.configure_server do |config|
  config.redis = { url: Settings.redis.url, namespace: "wcms-publisher-#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis.url, namespace: "wcms-publisher-#{Rails.env}" }
end

# Load the schedule for sidekiq-cron. Because this is in the initializers
# folder it will get run whenever the app starts up for the first time.
unless Rails.env == 'test'
  schedule_file = 'config/schedule.yml'
  if File.exist?(schedule_file)
    # The bang method will remove jobs that are no longer present
    # in the schedule array, update jobs that have the same name,
    # and create jobs with new names.
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end
