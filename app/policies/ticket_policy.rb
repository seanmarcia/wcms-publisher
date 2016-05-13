class TicketPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.has_role?(:designer)
  end
  alias :create? :index?
  alias :destroy? :index?
  alias :new? :index?
  alias :update? :index?
  alias :edit? :index?

  def permitted_attributes
    [:description, :link, :cost, :fine_print]
  end
end
