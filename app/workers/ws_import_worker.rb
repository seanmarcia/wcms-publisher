class WsImportWorker
  include Sidekiq::Worker

  def perform(obj, klass)
    case klass
    when "Article"
      WsArticleImport.new(obj).call
    end
  end
end
