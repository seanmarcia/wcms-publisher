class EventPolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  def create?
    true
  end
  alias :new? :create?
  alias :index? :create?
  alias :edit? :create?
  alias :show? :create?
  alias :destroy? :create?
  alias :update? :create?

  def permitted_attributes
    attrs = [
      :modifier_id, :title, :slug,
      :subtitle, :location_type, :custom_campus_location, :start_date, :end_date, :categories,
      :contact_name, :contact_email, :contact_phone, :paid,
      :admission_info, :audience, :map_url, :registration_info, :sponsor,
      :sponsor_site, :teaser,
    ]

    if user.admin?
      attrs += [:ws_source, :ws_id, :imported, :featured]
    end
  end
end
