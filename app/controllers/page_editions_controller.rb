class PageEditionsController < ApplicationController

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped, only: :index

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
  end

  def destroy
  end

  private

  def page_edition_params
    params.require(:page_edition).permit(:title, :slug, :site)
  end

end
