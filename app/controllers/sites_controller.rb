class SitesController < ApplicationController
  include ActivityLoggable

  before_filter :set_site, only: [:show, :edit, :update]
  before_filter :new_site_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @sites = policy_scope(Site)
    @sites = @sites.custom_search(params[:q]) if params[:q]
    @sites = @sites.page(params[:page]).per(25)
  end

  def show
    @page_editions = [
      {
        title: @site.title,
        id: nil,
        root: true,
        url: edit_site_url(@site),
        preview_url: @site.url,
        has_children: true
      }
    ] +
    policy_scope(@site.page_editions).asc(:title).map do |page|
      {
        type: 'page_edition',
        id: page.id.to_s,
        title: page.title,
        url: page_edition_url(page),
        preview_url: page.url,
        slug: page.slug,
        parent_id: (page.parent_page_id).try(:to_s),
        status: page.aasm_state,
        has_children: page.child_page_ids.length > 0
      }
    end
    # render json: @page_editions
  end

  def new
  end

  def create
    if @site.save
      log_activity(@site.previous_changes, parent: @site)
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
      log_activity(@site.previous_changes, parent: @site)
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
    params.require(:site).permit(*policy(@site || Site).permitted_attributes)
  end

  def set_site
    @site = Site.find(params[:id]) if params[:id]
    @page_name = @site.try(:title)
  end

  def pundit_authorize
    authorize (@site || Site)
  end
end
