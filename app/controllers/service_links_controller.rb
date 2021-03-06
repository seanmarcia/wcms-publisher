class ServiceLinksController < ApplicationController
  before_filter :set_service_link, only: [:show, :edit, :update]
  before_filter :new_service_link_from_params, only: [:new, :create]
  before_filter :pundit_authorize
  before_filter :new_audience_collection, only: [:edit, :update, :new, :create]

  def index
    @service_links = policy_scope(ServiceLink)

    unless @service_links.none?
      # Filter Results
      @service_links = @service_links.custom_search(params[:q]) if params[:q]
    end

    @service_links = @service_links.asc(:title).page(params[:page]).per(25)
  end

  def show
    @service_link = ServiceLink.find(params[:id])
    redirect_to [:edit, @service_link]
  end

  def new
    @service_link = ServiceLink.new
  end

  def create
    @service_link = ServiceLink.new(service_link_params)
    if @service_link.save
      flash[:notice] = "'#{@service_link.title}' created."
      redirect_to [:edit, @service_link]
    else
      render :new
    end
  end

  def edit
    @service_link = ServiceLink.find(params[:id])
  end

  def update
    @service_link = ServiceLink.find(params[:id])
    if @service_link.update_attributes(service_link_params)
      flash[:notice] = "'#{@service_link.title}' updated."
      redirect_to edit_service_link_path @service_link, page: params[:page]
    else
      render :edit
    end
  end

  private

  def new_audience_collection
    @service_link.audience_collection = AudienceCollection.new if @service_link.audience_collection.nil?
  end

  def new_service_link_from_params
    @service_link = ServiceLink.new(service_link_params)
  end

  def service_link_params
    permitted_params(:service_link)
  end

  def set_service_link
    @service_link = ServiceLink.find(params[:id]) if params[:id]
    @page_name = @service_link.try(:title)
  end

  def pundit_authorize
    authorize(@service_link || ServiceLink)
  end

end
