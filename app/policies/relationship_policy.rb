class RelationshipPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def create?
    user.admin?
  end
  def destroy?
    user.admin?
  end

  # We are not using permitted_attributes right now.
  # We are only querying params directly in the controller.
  # def permitted_attributes
  #   [:base_type, :base_id, :related_type, :related_id]
  # end
end
