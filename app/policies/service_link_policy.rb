class ServiceLinkPolicy < PermissionsPolicy
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
    attrs = [ :title, :slug, :url, :description, :topics_string, :keywords_string ]
    # Add audience collections
    attrs << { audience_collection: [ affiliations: [], schools: [], student_levels: [], class_standings: [],
      majors: [], housing_statuses: [], employee_types: [], departments: [] ] }
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :activity_logs
      page_admin?
    else
      false
    end
  end
end
