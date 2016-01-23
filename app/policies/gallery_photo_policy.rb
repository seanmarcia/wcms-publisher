class GalleryPhotoPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.has_role?(:designer)
  end
  alias :create? :index?
  alias :destroy? :index?
  alias :sort? :index?

  def permitted_attributes
    [:photo, :caption, :order]
  end
end
