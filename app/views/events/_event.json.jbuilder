json.id event.id.to_s
json.type "Event"
json.attributes do
  json.title event.title
  json.start_date event.start_date
  json.end_date event.end_date

  if params[:show_details].present?
    # Put things only for the show page in here
    json.slug                   event.slug
    json.modifier_id            event.modifier_id
    json.title                  event.title
    json.slug                   event.slug
    json.subtitle               event.subtitle
    json.location_type          event.location_type
    json.custom_campus_location event.custom_campus_location
    json.start_date             event.start_date
    json.end_date               event.end_date
    json.categories             event.categories
    json.contact_name           event.contact_name
    json.contact_email          event.contact_email
    json.contact_phone          event.contact_phone
    json.paid                   event.paid
    json.featured               event.featured
    json.admission_info         event.admission_info
    json.audience               event.audience
    json.map_url                event.map_url
    json.registration_info      event.registration_info
    json.sponsor                event.sponsor
    json.sponsor_site           event.sponsor_site
    json.teaser                 event.teaser
  end
end
# Attributes the user can edit
json.permitted_attributes policy(event).permitted_attributes
json.links do
  json.self url_for(event)
end
