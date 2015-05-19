CampusLocation.class_eval do
  scope :custom_search, -> query {
    begin
      if query.present?
        q = Regexp.new(query.to_s, Regexp::IGNORECASE)
        any_of({name: q},{description: q})
      end
    rescue RegexpError
      CampusLocation.none
    end
  }
end
