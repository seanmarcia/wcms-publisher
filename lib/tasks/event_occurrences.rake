namespace :event_occurrences do

  desc 'migrate event occurrences from event times'
  task migrate: [:environment] do
    # Migrate from event times to event_occurrences
    Event.each do |e|
      if e.event_occurrences.count == 0
        eo = e.event_occurrences.new(start_time: e.start_date, end_time: e.end_date)
        eo.save
        eo.add_to_index
      end
    end
  end
end
