class EventPolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if global_event_admin? || global_event_viewer?
        scope.all
      elsif event_viewer?
        scope.and({"$or"=>[
          {user_id: user.id.to_s},
          {'permissions.actor_id' => user.id.to_s},
          {:site_id.in => permitted_sites_ids }
        ]})
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
    can_edit?
  end

  alias :show? :edit?
  alias :destroy? :edit?
  alias :duplicate? :edit?

  def update?
    can_update?
  end

  def publish?
    event_publisher?
  end

  def permitted_aasm_events
    if publish?
      [:submit_for_review, :return_to_draft, :approve, :unapprove, :publish, :archive]
    elsif update?
      [:submit_for_review, :return_to_draft]
    else
      []
    end
  end

  def permitted_attributes
    pa = []
    # if its new than check that its an Event, otherwise check to see if its origin is wcms through the update? method
    # If the record is a draft it can be edited but if its in the review process only editors and above can edit it
    if record == Event || can_change_form_fields_by_aasm_state?(record.aasm_state) #((record.new_record? || update?) && (record.draft? || event_editor?))
      pa += [:title, :subtitle, :slug, :location_type, :campus_location_id, :custom_campus_location,
      :start_date, :end_date, :summary, :related_object_tags, :categories, :image, :contact_name,
      :contact_email, :contact_phone, :paid, :description, :publish_sidekiq_id, :archive_sidekiq_id,
      :crop_x, :crop_y, :crop_w, :crop_h, :imported, :ws_source, :ws_id, :user_id, :primary_page_id,
      :registration_link, :registration_button_text,
      audience: [], department_ids: [], group_ids: [], external_sponsor_ids: [],
      event_collection_ids: [], site_category_ids: [], link_ids: [],
      address: [:line1, :street, :city, :state, :zip, :use_associated_title],
      event_occurrences_attributes: [:id, :start_time, :end_time, :_destroy]]

      pa += [:presentation_data_json, :presentation_data_template_id]
      pa += [:end_of_head_html, :end_of_body_html] if can_manage?(:design)
      pa += [:publish_at, :archive_at, :featured] if event_publisher?
      pa += [:site_id] if record == Event || record.site_id.blank? || record.draft?
      pa += [:registration_info] if event_admin?
      pa = pa | SEO_FIELDS if user.admin? # Inherited from ApplicationPolicy
    end
    return pa
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :relationships, :presentation_data, :links, :tickets, :occurrences, :pages
      event_author?
    when :logs, :seo
      user.admin?
    when :permissions
      event_admin?
    when :design
      user.admin? || user.has_role?(:designer)
    else
      false
    end
  end

  private

  def can_edit?
    can_update? ||
    (record.site && event_author_for_site?(record.site))
  end

  def can_update?
    global_event_editor? ||
    record.user == user ||
    record.has_permission_to?(:edit, user) ||
    (record.site && event_editor_for_site?(record.site))
  end

  def can_change_form_fields_by_aasm_state?(aasm_state)
    case aasm_state.to_sym
    when :draft
      # global editor or higher, site editor or higher, owner, event with permission to edit
      global_event_editor? || (record.site && event_editor_for_site?(record.site)) || record.user == user || record.has_permission_to?(:edit, user)
    when :ready_for_review
      # global editor or higher, site editor or higher
      global_event_editor? || (record.site && event_editor_for_site?(record.site))
    when :approved
      # global editor or higher, site editor or higher
      global_event_editor? || (record.site && event_editor_for_site?(record.site))
    when :published
      # global editor or higher, site editor or higher, owner, event with permission to edit
      global_event_editor? || (record.site && event_editor_for_site?(record.site)) || record.user == user || record.has_permission_to?(:edit, user)
    when :archived
      # global editor or higher, site editor or higher
      global_event_editor? || (record.site && event_editor_for_site?(record.site))
    end
  end
end
