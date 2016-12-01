class FeaturePolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if feature_admin? || user.has_role?(:feature_viewer)
        scope.all
      elsif feature_author?
        sites = Site.with_any_permission_to([:feature_publisher, :feature_editor, :feature_author], user)
        feature_location_ids = sites.map(&:feature_locations).flatten
        scope.in(feature_location_id: feature_location_ids)
      else
        scope.none
      end
    end
  end

  def create?
    feature_author?
  end
  alias :new? :create?
  alias :search? :create?

  def sort?
    feature_publisher? || site_admin?
  end

  def index?
    feature_viewer?
  end

  def needs_publishing?
    feature_publisher?
  end

  def edit?
    site_feature_author?(record.feature_location)
  end
  alias :show? :edit?
  alias :destroy? :edit?
  alias :update? :edit?

  def publish?
    feature_publisher?
  end

  def permitted_aasm_events
    if publish?
      [:submit_for_review, :return_to_draft, :approve, :unapprove, :publish, :archive]
    elsif update?
      [:submit_for_review]
    end
  end

  def permitted_attributes
    pa = []
    # If the record is a draft it can be edited but if its in the review process only editors and above can edit it
    if record == Feature || ((record.try(:new_record?) || update?) && (record.draft? || feature_editor?))
      pa << [:title, :slug, :aasm_state, :publish_sidekiq_id, :archive_sidekiq_id,
             :body, :hd_video_url, :standard_video_url, :audio_url, :media_thumbnail_url,  :call_to_action_link,
             :call_to_action_text, :type, :layout, :image_type, :feature_location_id, :order]
      pa << [:publish_at, :archive_at] if feature_publisher?
    end
    return pa.flatten
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :feature
      true
    when :logs
      user.try(:admin?)
    else
      false
    end
  end
end
