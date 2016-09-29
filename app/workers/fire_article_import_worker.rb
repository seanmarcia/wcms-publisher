class FireArticleImportWorker
  include Sidekiq::Worker
  include WsHelper

  def perform(last_occurrence, current_occurrence)
    # Fetches articles from ws that have been modified within the last run time.
    # last_occurrence is past back as a timestamp and thus needs to be translated for ws.
    fetch_ws_articles([{'attribute' => 'date_modified', 'value' => Time.at(last_occurrence).to_datetime, 'comparison' => '>='}].to_json, 500, 0)
  end

  def manual_sync
    fetch_ws_articles([{'attribute' => 'date_modified', 'value' => 1.hour.ago.to_s, 'comparison' => '>='}].to_json, 500, 0)
    true
  end

  def get_all
    # Fetches all ws articles for syncing.
    fetch_ws_articles([].to_json, 500, 0)
  end

  private
  def fetch_ws_articles(criteria, limit, startat)
    # This will run while there are articles left to be synced in.
    while true
      articles = BiolaWebServices.news.get_articles(criteria: criteria, limit: limit, startat: startat)

      break if articles.blank?

      articles.each do |article|
        WsImportWorker.new.perform(article, 'Article') unless wcms_source?(article)
      end

      startat += limit
    end
  end
end
