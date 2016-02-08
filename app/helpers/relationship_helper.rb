module RelationshipHelper

  def remove_relationship_link(relationship)
    link_to "remove", relationship, method: :delete, data: { confirm: "Are you sure that you want to remove this relationship?" }
  end
end
