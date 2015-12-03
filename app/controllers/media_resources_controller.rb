class MediaResourcesController < ApplicationController
  include SetModifier

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
    if params[:media_resource]
      @media_resource = @medium.media_resources.new(media_resource_params)
    else
      @media_resource = @medium.media_resources.new
    end
  end

  def media_resource_params
    params.require(:media_resource).permit(*policy(@media_resource || MediaResource).permitted_attributes)
  end

  def set_media_resource
    @media_resource = @medium.media_resources.find(params[:id]) if params[:id]
  end

  def pundit_authorize
    authorize (@media_resource || MediaResource)
  end

end
