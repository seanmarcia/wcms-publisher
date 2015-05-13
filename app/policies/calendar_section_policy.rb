class CalendarSectionPolicy < ApplicationPolicy
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
    [:title, :start_date, :end_date]
  end
end
