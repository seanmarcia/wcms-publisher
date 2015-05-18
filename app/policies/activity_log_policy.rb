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
end
