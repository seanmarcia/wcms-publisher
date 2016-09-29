class WsExportWorker
  include Sidekiq::Worker

  def perform(obj_id, klass)
    case klass
    when "Article"
      WsArticleExport.new(id).call
    end
  end
end
