class MenusController < ApplicationController
  before_filter :set_page_editions

  def index
    authorize(Menu)
    @menus = policy_scope(Menu)

    unless @menus.none?
      # Filter Values
      @available_sites = Site.in(id: @menus.distinct(:site_id)).asc(:title)

      # Filter Results
      @menus = @menus.custom_search(params[:q]) if params[:q]
      @menus = @menus.by_site(params[:site]) if params[:site]
    end

    @menus = @menus.asc(:title).page(params[:page]).per(25)
  end

  def show
    @menu = Menu.find(params[:id])
    authorize(@menu)
    redirect_to [:edit, @menu]
  end

  def new
    @menu = Menu.new(menu_params)
    authorize(@menu)

    # Allow some default values set through the params
    @menu.site_id = params[:site_id]
    @menu.title = params[:title]
    # For some reason this isn't working yet
    # @menu.page_edition_ids = [params[:page_edition_id]] if params[:page_edition_id]
  end

  def create
    @menu = Menu.new(menu_params)
    authorize(@menu)
    if @menu.save && @menu.update_attributes(page_edition_ids: menu_params[:page_edition_ids])
      flash[:notice] = "'#{@menu.title}' created."
      redirect_to edit_menu_path(@menu, page: params[:page])
    else
      render :new
    end
  end

  def edit
    @menu = Menu.find(params[:id])
    authorize(@menu)
    @page_name = @menu.try(:title)
  end

  def update
    @menu = Menu.find(params[:id])
    authorize(@menu)
    if @menu.update_attributes(menu_params)
      flash[:notice] = "'#{@menu.title}' updated."
      redirect_to edit_menu_path(@menu, page: params[:page])
    else
      render :edit
    end
  end

  private

  def menu_params
    permitted_params(:menu)
  end

  def set_page_editions
    @sites = Site.where(has_page_editions: true)
    @page_editions = {}
    @sites.each do |site|
      @page_editions[site.id] = site.page_editions.asc(:slug).map{ |pe| { title: pe.slug, id: pe.id.to_s } }
    end
  end
end
