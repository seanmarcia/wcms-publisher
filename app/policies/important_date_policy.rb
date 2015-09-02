class ImportantDatePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.developer?
  end
  alias :show? :index?

  def create?
    user.admin? || user.developer?
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?
  alias :destroy? :create?

  def permitted_attributes
    attrs = [:title, :url, :start_date, :end_date, :deadline, {categories: []}, {audiences: []}, {calendar_ids: []}]
    attrs += [ audience_collection: [ affiliations: [], schools: [], student_levels: [], class_standings: [],
      majors: [], housing_statuses: [], employee_types: [], departments: [] ] ]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :activity_logs, :permissions
      user.admin? || user.developer?
    else
      false
    end
  end
end
