class EventOccurrencePolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  # Right now this is only used in the permitted_form_for @event form
  def index?
    true
  end
  alias :show? :index?
  alias :edit? :index?
  alias :update? :index?
  alias :new? :index?
  alias :create? :index?
  alias :destroy? :index?

  def permitted_attributes
    [:id, :start_time, :end_time, :_destroy]
  end

end
