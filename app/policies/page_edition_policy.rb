class PageEditionPolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if page_admin?
        scope.all
      else
        scope.where("$and" => [
          {
            "$or" => [
              # Either user has permission to a page through sites
              { "site_id" => { "$in"=> Array(permitted_site_ids) } },
              # Or through the page itself
              {
                "permissions.actor_type"=>"User",
                "permissions.actor_id"=>user.id.to_s,
                "permissions.ability"=>:edit
              }
            ]
          }
        ])
      end
    end

    def permitted_site_ids
      Site.with_any_permission_to([:page_edition_editor, :page_edition_publisher], user).pluck(:id)
    end
  end

  def index?
    page_editor? || site_page_author?
  end
  alias :show? :index?
  alias :compact_index? :index?
  alias :view_topics? :index?

  def create?
    site_page_author?
  end
  alias :new? :create?

  def edit?
    page_editor_for?(record)
  end
  alias :update? :edit?

  def destroy?
    user.admin? || (page_editor? && record.draft?)
  end

  def can_redirect?
    page_admin?
  end

  def create_tag?
    page_admin?
  end

  def publish?
    page_publisher_for?(record)
  end

  def permitted_aasm_events
    if publish?
      [:submit_for_review, :return_to_draft, :approve, :unapprove, :publish, :archive]
    elsif update?
      [:submit_for_review]
    end
  end

  def permitted_attributes
    attrs = super || []
    attrs += [ :title, :slug, :site_id, :parent_page_id, :body, :page_template, :modifier_id,
      {site_category_ids: []}, {attachment_ids: []}, {department_ids: []}
    ]
    attrs += [ :source_type, :source_id ]
    attrs += [ :topics_string, :keywords_string ]
    attrs += [ :presentation_data_json, :presentation_data_template_id, :keep_in_sync, :presentation_data_json_schema ]
    attrs += [ {redirect: [ :destination, :type, :query_string_handling ]} ] if user.admin?
    attrs += [ :publish_at, :archive_at, :featured ] if page_publisher_for?(record)
    attrs = attrs | SEO_FIELDS if user.admin? # Inherited from ApplicationPolicy

    attrs += [:end_of_head_html, :end_of_body_html, :page_layout] if can_manage?(:design)

    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :logs, :presentation_data, :attachments, :audience_collections, :relationships
      page_editor?
    when :permissions, :seo
      page_admin?
    when :design, :page_source
      user.admin? || user.has_role?(:designer)
    else
      false
    end
  end
end
