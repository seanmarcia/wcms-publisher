class MediaController < ApplicationController
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
      flash[:notice] = "'#{@medium.title}' updated."
      redirect_to edit_medium_path(@medium, page: params[:page])
    else
      render :edit
    end
  end

  private

  def new_medium_from_params
    @medium = Medium.new(medium_params)
  end

  def medium_params
    permitted_params(:medium)
  end

  def set_medium
    @medium = Medium.find(params[:id]) if params[:id]
    @page_name = @medium.try(:title)
  end

  def pundit_authorize
    authorize(@medium || Medium)
  end

end
