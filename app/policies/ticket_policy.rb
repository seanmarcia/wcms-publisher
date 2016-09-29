class TicketPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  # def index?
  #   user.admin? || user.has_role?(:designer)
  # end
  def create?
    event_editor? || user.admin? || user.event_admin?
  end
  
  alias :destroy? :create?
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?

  def event_editor?
    record.try(:event) && EventPolicy.new(user, record.try(:event)).edit?
  end

  def permitted_attributes
    [:description, :link, :cost, :fine_print]
  end
end
