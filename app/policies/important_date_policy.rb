class ImportantDatePolicy < ApplicationPolicy
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
    attrs = [:modifier_id, :title, :url, :start_date, :end_date, :deadline, {categories: []}, {audiences: []}, {calendar_ids: []}]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :logs, :audience_collections
      true
    when :permissions
      user.admin? || user.developer?
    else
      false
    end
  end
end
