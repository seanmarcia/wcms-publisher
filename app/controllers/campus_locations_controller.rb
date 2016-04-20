class CampusLocationsController < ApplicationController
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
      flash[:notice] = "'#{@campus_location.title}' created."
      redirect_to [:edit, @campus_location]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @campus_location.update_attributes(campus_location_params)
      flash[:notice] = "'#{@campus_location.title}' updated."
      redirect_to [:edit, @campus_location]
    else
      render :edit
    end
  end

  private

  def new_campus_location_from_params
    @campus_location = CampusLocation.new(campus_location_params)
  end

  def campus_location_params
    permitted_params(:campus_location)
  end

  def set_campus_location
    @campus_location = CampusLocation.find(params[:id]) if params[:id]
    @page_name = @campus_location.try(:title)
  end

  def pundit_authorize
    authorize (@campus_location || CampusLocation)
  end

end
