class SiteCategoryPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin?
  end
  alias :create? :index?
  alias :update? :index?
  alias :destroy? :index?

  def permitted_attributes
    [:title, :description, :type]
  end
end
