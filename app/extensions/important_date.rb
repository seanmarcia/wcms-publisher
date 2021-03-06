ImportantDate.class_eval do
  scope :by_calendar, -> calendar { where(calendar_ids: calendar) }
  scope :by_category, -> category { where(categories: category) }
  scope :by_audience, -> audience { where(audiences: audience) }
  scope :future_dates, -> { gte(start_date: Time.now) }
  scope :is_a_deadline, -> { where(deadline: true) }
  scope :by_last_change, -> last_change {
    return scoped if last_change.nil?
    where('updated_at' => { '$gte' => Time.parse(last_change.to_s) })
  }
  scope :custom_search, -> query {
    begin
      if query.present?
        q = Regexp.new(query.to_s, Regexp::IGNORECASE)
        any_of({title: q}, {audiences: q}, {categories: q})
      end
    rescue RegexpError
      ImportantDate.none
    end
  }
end
