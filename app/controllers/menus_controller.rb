class MenusController < ApplicationController
  include ActivityLoggable

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

    @menus = @menus.desc(:title).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @menu]
  end

  def new
  end

  def create
    if @menu.save
      log_activity(@menu.previous_changes, parent: @menu)

      flash[:notice] = "'#{@menu.title}' created."
      redirect_to edit_menu_path(@menu, page: params[:page])
    else
      render :new
    end
  end

  def edit
  end

  def update
    @menu.page_editions = [] # allows for unsetting of all previously set page_editions
    if @menu.update_attributes(menu_params)
      log_activity(@menu.previous_changes, parent: @menu)

      flash[:notice] = "'#{@menu.title}' updated."
      redirect_to edit_menu_path(@menu, page: params[:page])
    else
      render :edit
    end
  end

  private

  def new_menu_from_params
    if params[:menu]
      @menu = Menu.new(menu_params)
    else
      @menu = Menu.new
    end
  end

  def menu_params
    params.require(:menu).permit(*policy(@menu || Menu).permitted_attributes)
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
      @page_editions[site.id] = site.page_editions.map{ |pe| { title: pe.title, id: pe.id.to_s } }
    end
  end
end