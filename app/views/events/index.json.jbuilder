json.data do
  json.array! @events, partial: 'events/event', as: :event
end
