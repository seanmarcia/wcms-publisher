class SiteCategoriesController < ApplicationController
  include ActivityLoggable

  layout false
  before_filter :set_site
  before_filter :set_site_category, on: [:edit, :update]
  before_filter :new_site_category_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def create
    if @site.site_categories.new(site_category_params).save
      log_activity({"added"=>[nil, @site.site_categories.last.title]}, parent: @site, child: 'site_category', activity: 'create')
      flash[:info] = "Category has been successfully saved."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to edit_site_path(@site, page: "#{category_type}_categories")
  end

  def update
    if @site_category.update_attributes(site_category_params)
      log_activity(@site_category.previous_changes, parent: @site, child: 'site_category', activity: 'update')
      flash[:info] = "Category has been successfully updated."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to edit_site_path(@site, page: "#{category_type}_categories")
  end

  def destroy
    cached_category_type = category_type # you have to cache it before @site_category gets deleted.
    if @site_category.delete
      log_activity(@site_category.previous_changes, parent: @site, child: 'site_category', activity: 'destroy')
      flash[:info] = "Category has been successfully removed."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to edit_site_path(@site, page: "#{cached_category_type}_categories")
  end

  protected

  def category_type
    @site_category.try(:type).parameterize('_') || params[:site_category][:type].parameterize('_')
  end

  def set_site
    @site = Site.find(params[:site_id])
  end

  def set_site_category
    @site_category = @site.site_categories.where(id: params[:id]).first
    @page_name = @site_category.try(:name)
  end

  def new_site_category_from_params
    if params[:site_category]
      @site_category = SiteCategory.new(site_category_params)
    else
      @site_category = SiteCategory.new
    end
  end

  def site_category_params
    params.require(:site_category).permit(*policy(@site_category || SiteCategory).permitted_attributes)
  end

  def pundit_authorize
    authorize (@site_category || SiteCategory)
  end
end