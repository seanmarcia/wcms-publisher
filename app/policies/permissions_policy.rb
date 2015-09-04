class PermissionsPolicy < ApplicationPolicy
  private
  #############################################
  ######### PAGE EDITION PERMISSIONS ##########
  #############################################
  # Generic if a user has this role at all
  def page_admin?
    user.admin? ||
    user.developer? ||
    user.has_role?(:page_admin)
  end

  # States that the user is able to edit at least one page, either through role,
  # though site permissions, or through page permissions
  def page_editor?
    site_page_editor? ||
    PageEdition.with_permission_to(:edit, user).present?
  end

  # States that the user is able to edit this particular page
  def page_editor_for?(page)
    site_page_editor_for?(page.site) ||
    page.has_permission_to?(:edit, user)
  end

  # Only a page publisher if you have permissions to a page through site or role
  def page_publisher_for?(page)
    site_page_editor_for?(page.site)
  end

  # States that the user is a page_publisher for at least one site
  def site_page_publisher?
    page_admin? ||
    Site.with_permission_to(:page_publisher, user).present?
  end

  # States that the user is a page_editor or page_publisher for at least one site
  def site_page_editor?
    site_page_publisher? ||
    Site.with_permission_to(:page_editor, user).present?
  end

  # States that the user is a page_publisher for this particular site
  def site_page_publisher_for?(site)
    page_admin? ||
    site.has_permission_to?(:page_publisher, user)
  end

  # States that the user is a page_editor or page_publisher for this particular site
  def site_page_editor_for?(site)
    site_page_publisher_for?(site) ||
    site.has_permission_to?(:page_editor, user)
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
    site.has_permission_to?(:site_admin, user)
  end
end
