class ActorPolicy < ApplicationPolicy
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
  alias :destroy? :create?
end
