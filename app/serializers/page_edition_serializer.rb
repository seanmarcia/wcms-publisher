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
  attribute :has_children do
    object.child_page_ids.length > 0
  end
  attribute :preview_url do
    object.url
  end
end
