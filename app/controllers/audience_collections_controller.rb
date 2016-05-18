class AudienceCollectionsController < ApplicationController

  def update
    @audience_collection = @parent.audience_collection
    authorize @audience_collection
    if @audience_collection.update_attributes(audience_collection_params)
      flash[:notice] = "Audience Collection was successfully updated."
    else
      flash[:warning] = "Something went wrong. Please try again."
    end
    redirect_to [:edit, @parent, page: 'audience_collections']
  end


  private

  def audience_collection_params
    permitted_params(:audience_collection)
  end

end
