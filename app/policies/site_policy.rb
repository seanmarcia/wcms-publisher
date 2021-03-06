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
        # Return all sites that the user has access to edit
        site_ids = PageEditionPolicy::Scope.new(user, PageEdition).resolve.distinct(:site_id)
        # or where a user can author pages for
        site_ids = site_ids + Site.with_permission_to(:page_edition_author, user).pluck(:id)
        scope.where(:id.in => site_ids)
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
    attrs = [:modifier_id, :title, :url, :staging_url, :preferred_image_height, :preferred_image_width, :user_ids, :has_events, :has_articles,
      :has_features, :has_audience_collections, :has_page_editions, :site_layout, article_author_roles: [], event_author_roles: []]
    attrs = attrs | [:presentation_data_json, :presentation_data_template_id] | SEO_FIELDS if user.admin? # Inherited from ApplicationPolicy

    attrs
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :logs
      true
    when :permissions
      site_admin_for?(record)
    when :page_edition_categories
      site_admin_for?(record) && record.has_page_editions
    when :event_categories
      site_admin_for?(record) && record.has_events
    when :article_categories
      site_admin_for?(record) && record.has_articles
    when :feature_locations
      (site_admin_for?(record) || user.has_role?(:feature_admin)) && record.has_features
    when :design
      user.admin? || user.has_role?(:designer)
    when :presentation_data, :seo
      user.admin?
    else
      false
    end
  end
end
