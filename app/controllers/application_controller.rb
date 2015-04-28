class ApplicationController < WcmsApplicationController

  # We are inheriting from WcmsApplicationController.
  #  This contains many of the controller configuration code.

  before_filter :set_parent

  protected

  def set_parent
    if params[:page_edition_id].present?
      @parent = PageEdition.find(params[:page_edition_id])
    else
      @parent = nil
    end
  end

  def parent_edit_path(parent, options = {})
    send("edit_#{parent.class.to_s.underscore}_path", parent.id, options) if parent
  end
end
