class PageEditionSerializer < BaseSerializer
  attribute :title
  attribute :slug
  attribute :body
  attribute :parent_page_id do
    object.parent_page_id.try(:to_s)
  end
  attribute :status do
    object.aasm_state
  end
  attribute :preview_url do
    object.url
  end
  attribute :redirect_url do
    object.redirect.try(:destination)
  end
  attribute :updated_at

  # TODO: Only render these on show, is this possible?
  attribute :presentation_data
  attribute :schema do
    object.presentation_data_json_schema
  end
end
