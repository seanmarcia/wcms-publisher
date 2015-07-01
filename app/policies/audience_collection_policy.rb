class ImportantDatePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def show?
    user.admin? || user.developer?
  end

  def create?
    user.admin? || user.developer?
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?

  def permitted_attributes
    affiliations: [], schools: [], student_levels: [], class_standings: [], majors: [], housing_statuses: [], employee_types: [], departments: []
  end
end
