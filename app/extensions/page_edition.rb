PageEdition.class_eval do
  scope :by_site, -> site { where(site_id: site) }
  scope :by_page_template, -> template { where(page_template: template) }
  scope :by_last_change, -> last_change {
    return scoped if last_change.nil?
    where('updated_at' => { '$gte' => Time.parse(last_change.to_s) })
  }
  scope :custom_search, -> query {
    begin
      if query.present?
        q = Regexp.new(query.to_s, Regexp::IGNORECASE)
        any_of({title: q}, {slug: q})
      end
    rescue RegexpError
      PageEdition.none
    end
  }
end
