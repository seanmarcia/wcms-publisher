Calendar.class_eval do
  scope :by_tag, -> tag { where(tags: tag) }
  scope :custom_search, -> query {
    begin
      if query.present?
        q = Regexp.new(query.to_s, Regexp::IGNORECASE)
        any_of({title: q},{tags: q})
      end
    rescue RegexpError
      Calendar.none
    end
  }
end
