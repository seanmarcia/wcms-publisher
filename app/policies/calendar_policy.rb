class CalendarPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.developer?
  end
  alias :show? :index?

  def create?
    user.admin? || user.developer?
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?
  alias :destroy? :create?

  def permitted_attributes
    attrs = [:title, :start_date, :end_date, tags: []]
    attrs = attrs | SEO_FIELDS if user.admin? || user.developer? # Inherited from ApplicationPolicy
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :activity_logs, :permissions, :calendar_sections, :seo
      user.admin? || user.developer?
    else
      false
    end
  end
end
