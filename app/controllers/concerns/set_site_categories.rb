module SetSiteCategories
  extend ActiveSupport::Concern

  def set_categories(type)
    @sites = Site.where(has_page_editions: true)
    @site_categories = {}
    @sites.each do |site|
      @site_categories[site.id] = site.categories(type).map{ |cat| { title: cat.title, id: cat.id.to_s } }
    end
    @site_categories.each{|e| e.last.sort_by!{|s| s[:title]} }
  end
end
