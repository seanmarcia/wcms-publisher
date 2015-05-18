class CampusLocationsController < ApplicationController
  include ActivityLoggable
  
  before_filter :set_campus_location, only: [:show, :edit, :update]
  before_filter :new_campus_location_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @campus_locations = policy_scope(CampusLocation)
    @campus_locations = @campus_locations.custom_search(params[:q]) if params[:q]
    @campus_locations = @campus_locations.asc(:name).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @campus_location]
  end

  def new
  end

  def create
    if @campus_location.save
      log_activity(@campus_location.previous_changes, parent: @campus_location)
      redirect_to [:edit, @campus_location]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @campus_location.update_attributes(campus_location_params)
      log_activity(@campus_location.previous_changes, parent: @campus_location)
      redirect_to [:edit, @campus_location]
    else
      render :edit
    end
  end

  private

  def new_campus_location_from_params
    if params[:campus_location]
      @campus_location = CampusLocation.new(campus_location_params)
    else
      @campus_location = CampusLocation.new
    end
  end

  def campus_location_params
    params.require(:campus_location).permit(*policy(@campus_location || CampusLocation).permitted_attributes)
  end

  def set_campus_location
    @campus_location = CampusLocation.find(params[:id]) if params[:id]
    @page_name = @campus_location.try(:title)
  end

  def pundit_authorize
    authorize (@campus_location || CampusLocation)
  end

end
