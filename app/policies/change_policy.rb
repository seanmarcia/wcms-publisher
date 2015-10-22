class ChangePolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    def resolve
      scope.all
    end
  end

  def undo?
    user.admin?
  end
  alias :undo_destroy? :undo?
end
