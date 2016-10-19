Article.class_eval do
  scope :custom_search, -> query {
    begin
      if query.present?
        q = Regexp.new(query.to_s, Regexp::IGNORECASE)
        any_of({title: q})
      end
    rescue RegexpError
      Article.none
    end
  }
end
