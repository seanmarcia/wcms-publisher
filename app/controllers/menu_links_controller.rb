class MenuLinksController < ApplicationController
  layout false

  before_filter :set_menu
  before_filter :set_menu_link, only: [:show, :edit, :update, :destroy]
  before_filter :new_menu_link_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def new
  end

  def create
    if @menu_link.valid? && @menu.menu_links.create(menu_link_params)
      flash[:info] = 'Link successfully added.'
    else
      flash[:error] = 'Something went wrong. Please try again.'
    end
    redirect_to edit_menu_path(@menu, page: 'menu_links')
  end

  def edit
  end

  def update
    if @menu_link.update_attributes(menu_link_params)
      flash[:info] = "Link has been successfully updated."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to edit_menu_path(@menu, page: 'menu_links')
  end

  def destroy
    if @menu_link.destroy
      flash[:info] = "Link has been successfully removed."
    else
      flash[:error] = "Somthing went wrong. Please try again."
    end
    redirect_to :back
  end

  def sort
    params[:menu_link].each_with_index do |id, index|
      menu_link = @menu.menu_links.find(id)
      menu_link.update(order: index+1)
    end

    render nothing: true
  end

  private

  def set_menu
    @menu = Menu.find(params[:menu_id])
  end

  def set_menu_link
    @menu_link = @menu.menu_links.find(params[:id])
  end

  def new_menu_link_from_params
    if params[:menu_link]
      @menu_link = MenuLink.new(menu_link_params)
    else
      @menu_link = MenuLink.new
    end
  end

  def menu_link_params
    params.require(:menu_link).permit(*policy(@menu_link || MenuLink).permitted_attributes)
  end

  def pundit_authorize
    authorize (@menu_link || MenuLink)
  end
end
