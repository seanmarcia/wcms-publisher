class ApplicationController < WcmsApplicationController

  # We are inheriting from WcmsApplicationController.
  #  This contains many of the controller configuration code.

  protect_from_forgery with: :exception

  before_filter :set_parent

  protected

  def set_parent
    @parent = if params[:page_edition_id].present?
      PageEdition.find(params[:page_edition_id])
    elsif params[:calendar_id].present?
      Calendar.find(params[:calendar_id])
    elsif params[:important_date_id].present?
      ImportantDate.find(params[:important_date_id])
    elsif params[:campus_location_id].present?
      CampusLocation.find(params[:campus_location_id])
    elsif params[:menu_id].present?
      Menu.find(params[:menu_id])
    elsif params[:site_id].present?
      Site.find(params[:site_id])
    else
      nil
    end
  end

  def parent_edit_path(parent, options = {})
    send("edit_#{parent.class.to_s.underscore}_path", parent.id, options) if parent
  end
end
