class ApplicationMailer < ActionMailer::Base
  default(
    from: Settings.email.from,
    content_type: 'text/html'
  )

  def new_published_articles(article_ids)
    @articles = Article.in(id: article_ids)

    mail to: Settings.email.email_to, subject: "[News Publisher] #{@articles.count} articles have been published." if @articles.present?
  end
end
