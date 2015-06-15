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

  # Generic if a user has this role at all
  def page_publisher?
    page_admin? ||
    Site.with_permission_to(:page_publisher, user).present?
  end

  def page_editor?
    page_publisher? ||
    Site.with_permission_to(:page_editor, user).present?
  end

  # Site specific user roles
  def site_page_publisher?(site)
    page_admin? ||
    site.has_permission_to?(:page_publisher, user)
  end

  def site_page_editor?(site)
    site_page_publisher?(site) ||
    site.has_permission_to?(:page_editor, user)
  end
end
