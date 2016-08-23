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
    global_event_admin?
  end

  # Generic if a user has this role at all
  def event_publisher?
    event_admin? ||
    site_event_publisher? ||
    Event.with_permission_to(:publish, user).present?
  end

  def event_editor?
    event_publisher? ||
    site_event_editor? ||
    Event.with_permission_to(:edit, user).present?
  end

  def event_author?
    event_editor? ||
    site_event_author? ||
    Event.with_permission_to(:author, user).present?
  end

  def event_viewer?
    event_author? ||
    site_event_viewer? ||
    Event.with_permission_to(:view, user).present?
  end

  # Generic roles for any site
  def site_event_publisher?
    site_admin? ||
    global_event_publisher? ||
    Site.with_permission_to(:event_publisher, user).present?
  end

  def site_event_editor?
    site_event_publisher? ||
    global_event_editor? ||
    Site.with_permission_to(:event_editor, user).present?
  end

  def site_event_author?
    site_event_editor? ||
    global_event_author? ||
    Site.with_permission_to(:event_author, user).present? ||
    (Site.pluck(:event_author_roles).flatten.uniq & user.affiliations).present?
  end

  def site_event_viewer?
    site_event_author? ||
    global_event_viewer? ||
    Site.with_permission_to(:event_viewer, user).present?
  end

  # Global event roles (based on person not on another object)
  def global_event_admin?
    user.admin? ||
    user.has_role?(:event_admin)
  end

  def global_event_publisher?
    global_event_admin? ||
    user.has_role?(:event_publisher)
  end

  def global_event_editor?
    global_event_publisher? ||
    user.has_role?(:event_editor)
  end

  def global_event_author?
    global_event_editor? ||
    user.has_role?(:event_author)
  end

  def global_event_viewer?
    global_event_author? ||
    user.has_role?(:event_viewer)
  end

  # Site specific user roles
  def event_publisher_for_site?(site) # RENAME to event_publisher_for_site(site)
    global_event_admin? ||
    site_admin? ||
    site.has_permission_to?(:event_publisher, user)
  end

  def event_editor_for_site?(site)
    event_publisher_for_site?(site) ||
    global_event_editor? ||
    site.has_permission_to?(:event_editor, user)
  end

  def event_author_for_site?(site)
    event_editor_for_site?(site) ||
    global_event_author? ||
    site.has_permission_to?(:event_author, user) ||
    (site.event_author_roles & user.affiliations).present?
  end

  def permitted_sites_ids
    Site.where('permissions.actor_id' => user.id.to_s, :'permissions.ability'.in => [:site_admin, :event_author, :event_viewer, :event_editor, :event_publisher]).pluck(:id)
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
