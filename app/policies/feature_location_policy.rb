class FeatureLocationPolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if feature_admin?
        # Include every site that has features enabled.
        scope.in(site_id: Site.with_features_enabled.pluck(:id))
      elsif feature_author?
        scope.in(site_id: Site.with_any_permission_to([:feature_publisher, :feature_editor, :feature_author], user).with_features_enabled.pluck(:id) )
      else
        scope.none
      end
    end
  end

  def create?
    site_admin? || feature_admin?
  end
  alias :new? :create?
  alias :index? :create?
  alias :edit? :create?
  alias :show? :create?
  alias :destroy? :create?
  alias :update? :create?

  def permitted_attributes
    [:modifier_id, :title, :site_id, :url, :path, :slug, :preferred_image_height, :preferred_image_width]
  end
end
