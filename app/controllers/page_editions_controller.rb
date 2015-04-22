class PageEditionsController < ApplicationController

  before_filter :set_page_edition, only: [:show, :edit, :update]
  before_filter :new_page_edition_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @page_editions = PageEdition.all
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
    if @page_edition.update_attributes(page_edition_params)
      redirect_to [:edit, @page_edition]
    else
      render :edit
    end
  end

  private

  def new_page_edition_from_params
    if params[:page_edition]
      @page_edition = PageEdition.new(page_edition_params)
    else
      @page_edition = PageEdition.new
    end
  end

  def page_edition_params
    params.require(:page_edition).permit(*policy(@page_edition || PageEdition).permitted_attributes)
  end

  def set_page_edition
    @page_edition = PageEdition.find(params[:id]) if params[:id]
    @page_name = @page_edition.try(:title)
  end

  def pundit_authorize
    authorize (@page_edition || PageEdition)
  end

end
