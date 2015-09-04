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
        scope.where({
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
        })
      end
    end

    def permitted_site_ids
      Site.with_any_permission_to([:page_editor, :page_publisher], user).pluck(:id)
    end
  end

  def index?
    page_editor?
  end
  alias :show? :index?

  def create?
    site_page_editor?
  end
  alias :new? :create?

  def edit?
    page_editor_for?(record)
  end
  alias :update? :edit?

  def permitted_attributes
    attrs = [ :title, :slug, :site_id, :parent_page_id, :body, :page_template,
      site_category_ids: [], attachment_ids: [], department_ids: [],
      audience_collection: [ affiliations: [], schools: [], student_levels: [], class_standings: [],
      majors: [], housing_statuses: [], employee_types: [], departments: [] ]
    ]
    attrs += [ :topics_string, :keywords_string ]
    attrs += [ :presentation_data_json, :presentation_data_template_id ]
    attrs += [ redirect: [ :destination, :type, :query_string_handling ] ] if user.admin?
    attrs += [ :publish_at, :archive_at, :featured ] if page_publisher_for?(record)
    attrs = attrs | SEO_FIELDS if user.admin? # Inherited from ApplicationPolicy

    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :activity_logs, :permissions, :presentation_data, :attachments, :audience_collections, :seo
      page_admin?
    else
      false
    end
  end
end
