class PhotoGalleriesController < ApplicationController
  before_filter :set_photo_gallery, only: [:show, :edit, :update, :destroy]
  before_filter :new_photo_gallery_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @photo_galleries = policy_scope(PhotoGallery)
    @photo_galleries = @photo_galleries.custom_search(params[:q]) if params[:q]
    @photo_galleries = @photo_galleries.asc(:title).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @photo_gallery]
  end

  def new
  end

  def create
    if @photo_gallery.save
      flash[:notice] = "'#{@photo_gallery.title}' created."
      redirect_to [:edit, @photo_gallery]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @photo_gallery.update_attributes(photo_gallery_params)
      flash[:notice] = "'#{@photo_gallery.title}' updated."
      redirect_to edit_photo_gallery_path @photo_gallery, page: params[:page]
    else
      render :edit
    end
  end

  def destroy
    if @photo_gallery.destroy
      flash[:info] = "Gallery has been successfully removed. <a href=/wcms_components/changes/#{@photo_gallery.history_tracks.last.id}/undo_destroy>Undo</a>"
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to photo_galleries_path
  end

  private

  def new_photo_gallery_from_params
    if params[:photo_gallery]
      @photo_gallery = PhotoGallery.new(photo_gallery_params)
    else
      @photo_gallery = PhotoGallery.new
    end
  end

  def photo_gallery_params
    params.require(:photo_gallery).permit(*policy(@photo_gallery || PhotoGallery).permitted_attributes)
  end

  def set_photo_gallery
    @photo_gallery = PhotoGallery.find(params[:id]) if params[:id]
    @page_name = @photo_gallery.try(:title)
  end

  def pundit_authorize
    authorize (@photo_gallery || PhotoGallery)
  end
end
