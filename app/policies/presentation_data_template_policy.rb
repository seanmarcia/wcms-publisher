class PresentationDataTemplatePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
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

  def destroy?
    false
  end

  ##### Special non-action permissions
  def permitted_attributes
    [:title, :target_class, :schema_json, :json_schema, {generic_objects_ids: []}]
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil
      true
    when :activity_logs
      user.try(:admin?)
    else
      false
    end
  end
end
