class MenusController < ApplicationController
  before_filter :set_menu, only: [:show, :edit, :update]
  before_filter :new_menu_from_params, only: [:new, :create]
  before_filter :set_page_editions
  before_filter :pundit_authorize

  def index
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
    redirect_to [:edit, @menu]
  end

  def new
  end

  def create
    if @menu.save && @menu.update_attributes(page_edition_ids: menu_params[:page_edition_ids])
      flash[:notice] = "'#{@menu.title}' created."
      redirect_to edit_menu_path(@menu, page: params[:page])
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @menu.update_attributes(menu_params)
      flash[:notice] = "'#{@menu.title}' updated."
      redirect_to edit_menu_path(@menu, page: params[:page])
    else
      render :edit
    end
  end

  private

  def new_menu_from_params
    @menu = Menu.new(menu_params)
  end

  def menu_params
    permitted_params(:menu)
  end

  def set_menu
    @menu = Menu.find(params[:id]) if params[:id]
    @page_name = @menu.try(:title)
  end

  def pundit_authorize
    authorize (@menu || Menu)
  end

  def set_page_editions
    @sites = Site.where(has_page_editions: true)
    @page_editions = {}
    @sites.each do |site|
      @page_editions[site.id] = site.page_editions.asc(:slug).map{ |pe| { title: pe.slug, id: pe.id.to_s } }
    end
  end
end
