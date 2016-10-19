class WsArticleExport
  attr_reader :article

  def initialize(id)
    @article = Article.find(id)
    Rails.logger.info "WSArticleExport has started for ID: #{@article.id.to_s}"
  end

  def call
    export
  end

  private
  def export
    ws_article = BiolaWebServices.news.get_article!( aid: article.ws_id, source: 'WCMS' )
    # Paramater missing will be passed if the article.ws_id is nil
    begin
      if ws_article.first == ['error', 'Inexistant article'] || ws_article.first == ['error', 'Inexistant article ID'] || ws_article.first == ['error', 'Parameter missing']
        result = BiolaWebServices.new.post_article!(a: translate_to_ws.to_json )
      elsif ws_article['aid'] != nil
        result = BiolaWebServices.new.modify_article!(a: translate_to_ws.to_json, tomodify: [aid: article.ws_id] )
      end

      if result.present? && result.include?('error')
        Rails.logger.error "[ERROR] BiolaWebServices#export [article_id=#{@article.id.to_s}]: failed to post to ws. #{result}"
      else
        Rails.logger.info "WSArticleExport has finished for ID: #{@article.id.to_s}. Result: #{result}"
      end
    rescue => error
      Rails.logger.error "[ERROR] BiolaWebServices#export [article_id=#{@article.id.to_s}]: failed to post to ws. #{error}"
    end
  end

  def translate_to_ws
    {
      date_modified: article.updated_at,
      aid: article.ws_id,
      source: article.ws_source,
      pub_date: article.publish_at,
      headline: article.title,
      slug: article.slug,
      tags: set_tags.join(', '),
      summary: article.teaser,
      photo_url: article.image_url,
      body: article.body,
      removed: removed,
      author: article.author.try(:name)
    }
  end

  def article_id
    article.ws_id.to_i
  end

  def removed
    article.aasm_state == 'archived' ? 1 : 0
  end

  def set_tags
    article.topics + article.departments.map(&:to_s)
  end
end
