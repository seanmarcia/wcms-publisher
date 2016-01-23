class PhotoGalleryPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.has_role?(:designer)
  end
  alias :show? :index?

  def create?
    user.admin? || user.has_role?(:designer)
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?
  alias :destroy? :create?

  def permitted_attributes
    attrs = [:title, :slug]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :gallery, :logs
      true
    else
      false
    end
  end
end
