class AudienceCollectionPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def edit?
    user.present?
  end
  alias :update? :edit?
  
  def permitted_attributes
    [:modifier_id, affiliations: [], schools: [], student_levels: [], class_standings: [], majors: [], housing_statuses: [], employee_types: [], departments: []]
  end

end
