all_data ||= false

json.id page.id.to_s
json.type "PageEdition"
json.attributes do
  json.title page.title
  json.slug page.slug
  json.parent_page_id page.parent_page_id.try(:to_s)
  json.status page.aasm_state
  json.preview_url page.url
  json.redirect_url page.redirect.try(:destination)
  json.updated_at page.updated_at
  if all_data
    json.body page.body
    json.presentation_data page.presentation_data
    json.presentation_data_json_schema page.presentation_data_json_schema
  end
end
json.links do
  json.self url_for(page)
end
