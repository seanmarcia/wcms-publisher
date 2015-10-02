class ActivityLogPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.admin?
        scope.all
      end
    end
  end

  def create?
    user.admin?
  end

  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?

  def permitted_attributes
    [:reviewer_ids, :action_performed, :message, :snapshot, :child]
  end

end
