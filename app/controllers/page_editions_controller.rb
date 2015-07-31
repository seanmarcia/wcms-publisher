class PageEditionsController < ApplicationController
  include ActivityLoggable
  include SetSiteCategories

  before_filter :set_page_edition, only: [:show, :edit, :update]
  before_filter :new_page_edition_from_params, only: [:new, :create]
  before_filter :set_categories_for_page_edition
  before_filter :pundit_authorize
  before_filter :new_audience_collection, only: [:edit, :update, :new, :create]

  def index
    @page_editions = policy_scope(PageEdition).asc(:title)
    @available_sites = Site.in(id: @page_editions.distinct(:site_id)).asc(:title)

    @page_tree = build_tree(@available_sites, @page_editions)
    # render json: @page_tree
  end

  def show
    @page_edition = PageEdition.find(params[:id])
    redirect_to [:edit, @page_edition]
  end

  def new
    @page_edition = PageEdition.new
  end

  def create
    @page_edition = PageEdition.new(page_edition_params)
    if @page_edition.save
      log_activity(@page_edition.previous_changes, parent: @page_edition)
      update_state
      flash[:notice] = "'#{@page_edition.title}' created."
      redirect_to [:edit, @page_edition]
    else
      render :new
    end
  end

  def edit
    @page_edition = PageEdition.find(params[:id])
  end

  def update
    @page_edition = PageEdition.find(params[:id])
    @page_edition.site_categories = []
    if @page_edition.update_attributes(page_edition_params)
      log_activity(@page_edition.previous_changes, parent: @page_edition, child: @page_edition.audience_collection.previous_changes)
      update_state
      flash[:notice] = "'#{@page_edition.title}' updated."
      redirect_to edit_page_edition_path @page_edition, page: params[:page]
    else
      render :edit
    end
  end

  private

  def new_audience_collection
    @page_edition.audience_collection = AudienceCollection.new if @page_edition.audience_collection.nil?
  end

  def new_page_edition_from_params
    if params[:page_edition]
      @page_edition = PageEdition.new(page_edition_params)
    else
      @page_edition = PageEdition.new
    end
  end

  def page_edition_params
    # params.require(:page_edition).permit(*policy(@page_edition || PageEdition).permitted_attributes)
    params[:page_edition][:meta_keywords] = params[:page_edition][:meta_keywords].split(',') unless params[:page_edition][:meta_keywords].nil?

    # I'm not using `require` here because it could be blank when updating presentation data
    ActionController::Parameters.new(params[:page_edition]).permit(*policy(@page_edition || PageEdition).permitted_attributes).tap do |whitelisted|
      # You have to whitelist the hash this way, see https://github.com/rails/rails/issues/9454
      whitelisted[:presentation_data] = params[:pdata] if params[:pdata].present?
    end
  end

  def set_page_edition
    @page_edition = PageEdition.find(params[:id]) if params[:id]
    @page_name = @page_edition.try(:title)
  end

  def pundit_authorize
    authorize (@page_edition || PageEdition)
  end

  def update_state
    if params[:published].present? && !@page_edition.published?
      @page_edition.publish!
      log_activity(@page_edition.previous_changes, parent: @page_edition)
    elsif params[:archived].present? && !@page_edition.archived?
      @page_edition.archive!
      log_activity(@page_edition.previous_changes, parent: @page_edition)
    end
  end

  def set_categories_for_page_edition
    set_categories('Page Edition')
  end

  def build_tree(sites, pages)
    [{id: 'sites', title: "Sites"}] +
    sites.map do |site|
      {
        type: 'site',
        id: site.id.to_s,
        title: site.title,
        url: nil,
        parent_id: 'sites'
      }
    end +
    pages.map do |page|
      {
        type: 'page_edition',
        id: page.id.to_s,
        title: page.title,
        url: page_edition_url(page),
        preview_url: page.url,
        parent_id: (page.parent_page_id || page.site_id).try(:to_s),
        status: page.aasm_state
      }
    end
  end
end
