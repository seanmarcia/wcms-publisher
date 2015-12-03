class ServiceLinkPolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.admin?
  end
  alias :show? :index?

  def create?
    user.admin?
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?

  def permitted_attributes
    attrs = [ :modifier_id, :title, :slug, :url, :description, :topics_string, :keywords_string ]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :logs, :audience_collections
      true
    else
      false
    end
  end
end
