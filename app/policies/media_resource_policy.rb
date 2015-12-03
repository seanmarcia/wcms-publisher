class MediaResourcePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    media_editor?
  end
  alias :create? :index?
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?
  alias :destroy? :create?

  def permitted_attributes
    attrs = [:modifier_id, :type, :url]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :logs, :permissions
      user.admin? || user.developer?
    else
      false
    end
  end
end
