class FeatureLocationsController < ApplicationController
  before_filter :set_feature_location, only: [:update, :destroy]
  before_filter :new_feature_location_from_params, only: :create
  before_filter :pundit_authorize

  def create
    if @feature_location.save
      flash[:info] = "#{@feature_location} was created."
    else
      # This is to show the validation errors for a feature location
      view_context.content_for(:message_list) do
        flash[:error] = @feature_location.errors.full_messages.join(', ')
      end
    end
    redirect_to edit_site_path @feature_location.site, page: "feature_locations"
  end

  def update
    if @feature_location.update_attributes(feature_location_params)
      flash[:info] = "#{@feature_location} changes were saved."
    else
      # This is to show the validation errors for a feature location
      view_context.content_for(:message_list) do
        flash[:error] = @feature_location.errors.full_messages.join(', ')
      end
    end
    redirect_to edit_site_path @feature_location.site, page: "feature_locations"
  end

  def destroy
    if @feature_location.destroy
      flash[:info] = "Feature Location has been successfully removed."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to edit_site_path(@feature_location.site, page: "feature_locations")
  end

  protected

  def new_feature_location_from_params
    @feature_location = FeatureLocation.new(feature_location_params)
  end

  def feature_location_params
    permitted_params(:feature_location)
  end

  def set_feature_location
    @feature_location = FeatureLocation.find(params[:id])
    @page_name = @feature_location.try(:name)
  end

  def pundit_authorize
    authorize(@feature_location || FeatureLocation)
  end
end
