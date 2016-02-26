class GalleryPhotosController < ApplicationController
  before_action :set_parent
  before_filter :set_gallery_photo, only: [:destroy]

  def create
    authorize GalleryPhoto # Not sure how to authorize this array when it hasn't been built so just authorizing that the user can create gallery photo objects in general

    if params[:gallery_photos].present?
      @upload_response = []

      Array(params[:gallery_photos]).each do |gallery_photo|
        @upload_response << @parent.gallery_photos.new(photo: gallery_photo.last[:photo], caption: gallery_photo.last[:caption]).save
      end

      if @upload_response.include? false
        flash[:warning] = "One or more of the files failed to upload because they are not recognized as images."
      end
      redirect_to polymorphic_url([:edit, @parent], page: params[:page])
    end
  end

  def destroy
    authorize @gallery_photo

    @gallery_photo.destroy

    redirect_to :back
  end

  def sort
    authorize GalleryPhoto
    GalleryPhotos.new(@parent, params).sort_gallery_photos_for_parent
    render :nothing => true
  end

  private

  def set_parent
    if params[:department_id].present?
      @parent = Department.find(params[:department_id])
    elsif params[:bio_edition_id].present?
      @parent = BioEdition.find(params[:bio_edition_id])
    elsif params[:custom_profile_id].present?
      @parent = CustomProfile.find(params[:custom_profile_id])
    elsif params[:photo_gallery_id].present?
      @parent = PhotoGallery.find(params[:photo_gallery_id])
    end
    @page_name = @parent.try(:title)
  end

  def set_gallery_photo
    @gallery_photo = @parent.gallery_photos.find(params[:id])
  end
end
