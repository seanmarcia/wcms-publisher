class UserPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.developer?
        scope.all
      else
        scope.none
      end
    end
  end

  def index?
    user.developer?
  end

  def impersonate?
    user.developer?
  end

  def stop_impersonating?
    true
  end

end
