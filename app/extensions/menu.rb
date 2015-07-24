Menu.class_eval do
  scope :by_site, -> site { where(site_id: site) }
  scope :custom_search, -> query {
    begin
      if query.present?
        q = Regexp.new(query.to_s, Regexp::IGNORECASE)
        any_of({title: q},{slug: q})
      end
    rescue RegexpError
      Menu.none
    end
  }
end
