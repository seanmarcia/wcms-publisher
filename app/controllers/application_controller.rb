class ApplicationController < WcmsApplicationController
  # We are inheriting from WcmsApplicationController.
  #  This contains many of the controller configuration code.

  protect_from_forgery with: :exception

  before_filter :set_parent

  protected

  def set_parent
    @parent =
      if params[:page_edition_id].present?
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
      elsif params[:service_link_id].present?
        ServiceLink.find(params[:service_link_id])
      end
  end

  def parent_edit_path(parent, options = {})
    send("edit_#{parent.class.to_s.underscore}_path", parent.id, options) if parent
  end

  # permitted_params(:name, [&block])
  #
  # Example usage:
  #
  #   permitted_params(:page_edition) do |p|
  #     # process params before permit
  #   end.tap do |p|
  #     # process params after permit
  #   end
  #
  def permitted_params(name, &block)
    return {} unless params[name]
    temp_params = params.require(name)

    # This allows you to process any of the fields before it is passed
    # through the permit policy
    block.call(temp_params) if block_given?

    policy_item = instance_variable_get("@#{name}") || name.to_s.classify.constantize
    temp_params.permit(*policy(policy_item).permitted_attributes).set_modifier(current_user)
  end
end
