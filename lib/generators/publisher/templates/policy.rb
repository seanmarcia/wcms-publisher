class <%= class_name %>Policy < ApplicationPolicy
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
    attrs = <%= Array(attributes).map do |attr|
      if attr.type == :array
        { attr.name.to_sym => [] }
      else
        attr.name.to_sym
      end
    end %>
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
