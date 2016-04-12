class AddressPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def create?
    event_author?
  end
  alias :new? :create?
  alias :edit? :create?
  alias :update? :create?

  def permitted_attributes
    [:line1, :street, :city, :state, :zip, :use_associated_title]
  end
end
