class MediaResourcesController < ApplicationController
  before_action :set_medium, :pundit_authorize

  def create
    new_media_resource_from_params
    @media_resource.save

    respond_to do |format|
      format.html { redirect_to [:edit, @medium] }
      format.js { render :index }
    end
  end

  def destroy
    set_media_resource
    @media_resource.destroy

    respond_to do |format|
      format.html { redirect_to [:edit, @medium] }
      format.js { render :index }
    end
  end

  private

  def set_medium
    @medium = Medium.find(params[:medium_id])
  end

  def new_media_resource_from_params
    @media_resource = @medium.media_resources.new(media_resource_params)
  end

  def media_resource_params
    permitted_params(:media_resource)
  end

  def set_media_resource
    @media_resource = @medium.media_resources.find(params[:id]) if params[:id]
  end

  def pundit_authorize
    authorize(@media_resource || MediaResource)
  end

end
