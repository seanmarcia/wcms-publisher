class WsArticleImport
  attr_reader :article

  def initialize(article)
    @article = article
  end

  def call
    # Find an article if it has already been added
    existing_article = Article.where(ws_id: article['aid'], ws_source: article['source']).first
    # Update or create articles
    if existing_article.present?
      existing_article.update_attributes set_article_attrs
    else
      a = Article.create set_article_attrs
      changes = a.previous_changes
      a.set_slug
    end
  end

  private
  def set_article_attrs
    {
      updated_at: article['date_modified'],
      ws_id: article['aid'],
      ws_source: article['source'],
      publish_at: article['pub_date'],
      title: article['headline'],
      slug: article['slug'],
      topics: article['tags'].try(:split, ', '),
      description: article['summary'],
      remote_image_url: article['photo_url'],
      body: article['body'],
      archive_at: removed,
      ws_author: article['author'],
      aasm_state: aasm,
      imported: true
    }
  end

  def removed
    article['removed'] == '1' ? Time.now : nil
  end

  def aasm
    removed.present? ? 'archived' : 'published'
  end
end
