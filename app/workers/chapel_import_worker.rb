class ChapelImportWorker
  include Sidekiq::Worker

  def perform
    ImportChapels.new.call
  end
end
