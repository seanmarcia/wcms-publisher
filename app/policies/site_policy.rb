class SitePolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.with_any_permission_to([:site_admin], user)
      end
    end
  end


  def create?
    site_admin?
  end
  alias :new? :create?

  def index?
    site_admin?
  end
  alias :search? :index?
  alias :show? :index?

  def edit?
    site_admin_for?(record)
  end
  alias :update? :edit?

  def destroy?
    false
  end

  def permitted_attributes
    [:title, :url, :preferred_image_height, :preferred_image_width, :user_ids, :has_events, :has_articles,
      :has_features, :has_audience_collections, :has_page_editions, article_author_roles: [], event_author_roles: []]
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :activity_logs, :permissions
      site_admin_for?(record)
    when :page_edition_categories
      site_admin_for?(record) && record.has_page_editions
    when :event_categories
      site_admin_for?(record) && record.has_events
    when :article_categories
      site_admin_for?(record) && record.has_articles
    when :feature_locations
      (site_admin_for?(record) || user.has_role?(:feature_admin)) && record.has_features
    else
      false
    end
  end
end
