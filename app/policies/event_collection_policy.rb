class EventCollectionPolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  # Right now this is only used in the permitted_form_for @event form
  def index?
    user.admin? || user.has_role?(:designer)
  end
  alias :show? :index?
  alias :edit? :index?
  alias :update? :index?
  alias :new? :index?
  alias :create? :index?
  alias :destroy? :index?

  def permitted_attributes
    [:title, :primary_page_id]
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :relationships, :pages
      user.admin? || user.has_role?(:designer)
    when :logs
      user.admin?
    else
      false
    end
  end

end
