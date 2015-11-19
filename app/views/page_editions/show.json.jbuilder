json.data do
  json.array! [@page_edition], partial: 'page_editions/page_edition', as: :page, locals: {all_data: true}
end
