module SetSiteCategories
  extend ActiveSupport::Concern

  def set_categories(type)
    @sites = Site.any_of({has_page_editions: true}, {has_articles: true}, {has_events: true}, {has_features: true})
    @site_categories = {}
    @sites.each do |site|
      @site_categories[site.id] = site.categories(type).asc(:title).map{ |cat| { title: cat.title, id: cat.id.to_s } }
    end
  end
end
