json.data do
  json.array! @page_editions, partial: 'page_editions/page_edition', as: :page
end
