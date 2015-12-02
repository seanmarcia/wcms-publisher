class MediaController < ApplicationController
  include ActivityLoggable

  before_filter :set_medium, only: [:show, :edit, :update]
  before_filter :new_medium_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @media = policy_scope(Medium)

    unless @media.none?
      @media = @media.custom_search(params[:q]) if params[:q]
    end

    @media = @media.asc(:title).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @medium]
  end

  def new
  end

  def create
    if @medium.save
      log_activity(@medium.previous_changes, parent: @medium)
      flash[:notice] = "'#{@medium.title}' created."
      redirect_to [:edit, @medium]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @medium.update_attributes(medium_params)
      log_activity(@medium.previous_changes, parent: @medium)
      flash[:notice] = "'#{@medium.title}' updated."
      redirect_to edit_medium_path(@medium, page: params[:page])
    else
      render :edit
    end
  end

  private

  def new_medium_from_params
    if params[:medium]
      @medium = Medium.new(medium_params)
    else
      @medium = Medium.new
    end
  end

  def medium_params
    params.require(:medium).permit(*policy(@medium || Medium).permitted_attributes)
  end

  def set_medium
    @medium = Medium.find(params[:id]) if params[:id]
    @page_name = @medium.try(:title)
  end

  def pundit_authorize
    authorize (@medium || Medium)
  end

end
