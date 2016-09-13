class CalendarPolicy < PermissionsPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
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
  alias :destroy? :create?

  def permitted_attributes
    attrs = [:modifier_id, :title, :start_date, :end_date, tags: []]
    attrs = attrs | SEO_FIELDS if user.admin? # Inherited from ApplicationPolicy
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :logs
      true
    when :calendar_sections, :seo
      calendar_editor?
    when :permissions
      user.admin?
    else
      false
    end
  end
end
