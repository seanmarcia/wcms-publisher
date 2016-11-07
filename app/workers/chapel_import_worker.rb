class ChapelImportWorker
  include Sidekiq::Worker

  def perform
    require 'rake'
    Rails.application.load_tasks
    Rake::Task['import:chapel_events'].invoke
  end
end
