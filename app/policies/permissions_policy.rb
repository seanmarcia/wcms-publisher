class PermissionsPolicy < ApplicationPolicy
  #############################################
  ######### PAGE EDITION PERMISSIONS ##########
  #############################################
  # Generic if a user has this role at all
  def page_admin?
    user.admin?
  end

  # States that the user is able to edit at least one page, either through role,
  # though site permissions, or through page permissions
  def page_editor?
    site_page_editor? ||
    PageEdition.with_permission_to(:edit, user).present?
  end

  # States that the user is able to edit this particular page
  def page_editor_for?(page)
    site_page_editor_for?(page.try(:site)) ||
    (page && page.has_permission_to?(:edit, user))
  end

  # Only a page publisher if you have permissions to a page through site or role
  def page_publisher_for?(page)
    # On create the class is passed into this method instead of an instance
    # So if that is the case we can only check if the person is a site_page_publisher,
    #  which isn't strictly correct, but it is probably better than restricting only to admins.
    if page == PageEdition
      site_page_publisher?
    else
      site_page_editor_for?(page.try(:site))
    end
  end

  # States that the user is a page_edition_publisher for at least one site
  def site_page_publisher?
    page_admin? ||
    Site.with_permission_to(:page_edition_publisher, user).present?
  end

  # States that the user is a page_editor or page_edition_publisher for at least one site
  def site_page_editor?
    site_page_publisher? ||
    Site.with_permission_to(:page_edition_editor, user).present?
  end

  # States that the user is a page_author or page_edition_editor for at least one site
  def site_page_author?
    site_page_editor? ||
    Site.with_permission_to(:page_edition_author, user).present?
  end

  # States that the user is a page_edition_publisher for this particular site
  def site_page_publisher_for?(site)
    page_admin? ||
    (site && site.has_permission_to?(:page_edition_publisher, user))
  end

  # States that the user is a page_editor or page_edition_publisher for this particular site
  def site_page_editor_for?(site)
    site_page_publisher_for?(site) ||
    (site && site.has_permission_to?(:page_edition_editor, user))
  end


  #############################################
  ############ EVENT PERMISSIONS ##############
  #############################################

  # Generic if a user has this role at all
  def event_admin?
    user.admin? ||
    user.has_role?(:event_admin)
  end

  # Generic if a user has this role at all
  def event_publisher?
    event_admin? ||
    Site.with_permission_to(:event_publisher, user).present?
  end

  def event_editor?
    event_publisher? ||
    Site.with_permission_to(:event_editor, user).present?
  end

  def event_author?
    event_editor? ||
    user.has_role?(:employee) ||
    Site.with_permission_to(:event_author, user).present?
  end

  def event_viewer?
    event_author? ||
    user.has_role?(:event_viewer)
  end

  # Site specific user roles
  def site_event_publisher?(site)
    event_admin? ||
    site.has_permission_to?(:event_publisher, user)
  end

  def site_event_editor?(site)
    site_event_publisher?(site) ||
    site.has_permission_to?(:event_editor, user)
  end

  def site_event_author?(site)
    site_event_editor?(site) ||
    site.has_permission_to?(:event_author, user) ||
    (site.event_author_roles & user.affiliations).present?
  end

  #############################################
  ########## FEATURES PERMISSIONS #############
  #############################################
  # Generic if a user has this role at all
  def feature_admin?
    user.admin? ||
    user.has_role?(:feature_admin)
  end

  # Generic if a user has this role at all
  def feature_publisher?
    feature_admin? ||
    Site.with_permission_to(:feature_publisher, user).present?
  end

  def feature_editor?
    feature_publisher? ||
    Site.with_permission_to(:feature_editor, user).present?
  end

  def feature_author?
    feature_editor? ||
    Site.with_permission_to(:feature_author, user).present?
  end

  def feature_viewer?
    feature_author? ||
    user.has_role?(:feature_viewer)
  end

  # Site specific user roles
  def site_feature_publisher?(feature_location)
    feature_admin? ||
    feature_location.site.has_permission_to?(:feature_publisher, user)
  end

  def site_feature_editor?(feature_location)
    site_feature_publisher?(feature_location) ||
    feature_location.site.has_permission_to?(:feature_editor, user)
  end

  def site_feature_author?(feature_location)
    site_feature_editor?(feature_location) ||
    feature_location.site.has_permission_to?(:feature_author, user)
  end


  #############################################
  ############# SITES PERMISSIONS #############
  #############################################

  def site_admin?
    user.admin? ||
    Site.with_permission_to(:site_admin, user).present?
  end

  def site_admin_for?(site)
    user.admin? ||
    (site && site.has_permission_to?(:site_admin, user))
  end


  #############################################
  ############# ACTOR PERMISSIONS #############
  #############################################
  def create_actor?
    user.admin?
  end
  alias :destroy_actor? :create_actor?
end
