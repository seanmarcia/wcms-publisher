class SitesController < ApplicationController

  before_filter :set_site, only: [:show, :edit, :update]
  before_filter :new_site_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @sites = policy_scope(Site)
    @sites = @sites.custom_search(params[:q]) if params[:q]
    @sites = @sites.asc(:title)
    @sites = @sites.page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @site]
  end

  def new
  end

  def create
    if @site.save
      flash[:info] = "#{@site} was created."
      redirect_to edit_site_path @site
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @site.update_attributes(site_params)
      flash[:info] = "#{@site} changes were saved."
      redirect_to edit_site_path(@site, page: params[:page])
    else
      render :edit
    end
  end

  private

  def new_site_from_params
    if params[:site]
      @site = Site.new(site_params)
    else
      @site = Site.new
    end
  end

  def site_params
    permitted_params(:site)
  end

  def set_site
    @site = Site.find(params[:id]) if params[:id]
    @page_name = @site.try(:title)
  end

  def pundit_authorize
    authorize (@site || Site)
  end
end
