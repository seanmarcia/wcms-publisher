ServiceLink.class_eval do
  scope :custom_search, -> query {
    begin
      if query.present?
        q = Regexp.new(query.to_s, Regexp::IGNORECASE)
        any_of({title: q}, {slug: q}, {url: q})
      end
    rescue RegexpError
      ServiceLink.none
    end
  }
end
