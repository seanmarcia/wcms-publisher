class EventPolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if event_admin? || user.has_role?(:event_viewer)
        scope.all
      elsif event_editor?
        scope.in(site_id: Site.with_any_permission_to([:event_publisher, :event_editor], user).pluck(:id))
      elsif event_author?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end

  def create?
    event_author?
  end
  alias :new? :create?
  alias :search? :create?

  def index?
    create? || event_viewer?
  end

  def update_from_ws?
    event_admin?
  end

  def edit?
    site_event_author?(record.site)
  end
  alias :show? :edit?
  alias :destroy? :edit?
  alias :duplicate? :edit?

  def update?
    site_event_editor?(record.site) || record.user == user
  end

  def publish?
    event_publisher?
  end

  def permitted_attributes
    pa = []
    # if its new than check that its an Event, otherwise check to see if its origin is wcms through the update? method
    # If the record is a draft it can be edited but if its in the review process only editors and above can edit it
    if record == Event || ((record.new_record? || update?) && (record.draft? || event_editor?))
      pa += [:title, :subtitle, :slug, :location_type, :campus_location_id, :custom_campus_location,
      :start_date, :end_date, :summary, :related_object_tags, :categories, :image, :contact_name,
      :contact_email, :contact_phone, :paid, :description, :publish_sidekiq_id, :archive_sidekiq_id,
      :crop_x, :crop_y, :crop_w, :crop_h, :imported, :ws_source, :ws_id, :user_id, audience: [], department_ids: [],
      group_ids: [], external_sponsor_ids: [], event_collection_ids: [], site_category_ids: [], link_ids: [],
      address: [:line1, :street, :city, :state, :zip, :use_associated_title],
      event_occurrences_attributes: [:id, :start_time, :end_time, :_destroy]]

      pa += [:presentation_data_json, :presentation_data_template_id]
      pa += [:publish_at, :archive_at, :featured] if event_publisher?
      pa += [:site_id] if record == Event || record.site_id.blank? || record.draft?
      pa = pa | SEO_FIELDS if user.admin? # Inherited from ApplicationPolicy
    end
    return pa
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :relationships, :presentation_data, :links, :tickets, :occurrences
      event_author?
    when :logs, :seo
      user.admin?
    else
      false
    end
  end
end
