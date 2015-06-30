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
      elsif page_publisher?
        scope.in(site_id: Site.with_any_permission_to([:page_editor], user).pluck(:id))
      elsif page_editor?
        scope.in(site_id: Site.with_any_permission_to([:page_editor], user).pluck(:id))
      else
        scope.none
      end
    end
  end

  def index?
    user.admin? || user.developer?
  end
  alias :show? :index?

  def create?
    page_editor?
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?

  def permitted_attributes
    attrs = [:title, :slug, :site_id, :body, :page_template, attachment_ids: []]
    attrs += [audience_collection: [affiliations: [], schools: [], student_levels: [], class_standings: [], majors: [], housing_statuses: [], employee_types: [], departments: []]]
    attrs += [:presentation_data_json, :presentation_data_template_id]
    attrs += [:publish_at, :archive_at, :featured] if page_publisher?

    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :profile
      true
    when :activity_logs, :permissions, :presentation_data, :attachments, :audience_collections
      page_admin?
    else
      false
    end
  end
end
