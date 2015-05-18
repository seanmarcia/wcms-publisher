class ActivityLogPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin? || user.developer?
        scope.all
      end
    end
  end

  def create?
    user.admin? || user.developer?
  end

  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?

  def permitted_attributes
    [:reviewer_ids, :action_performed, :message, :snapshot, :child]
  end
  
end
