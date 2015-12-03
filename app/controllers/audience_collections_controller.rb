class AudienceCollectionsController < ApplicationController
  include SetModifier

  before_filter :set_audience_collection, only: [:update]
  before_filter :pundit_authorize

  def update
    if @audience_collection.update_attributes(audience_collection_params)
      flash[:notice] = "Audience Collection was successfully updated."
    else
      flash[:warning] = "Something went wrong. Please try again."
    end
    redirect_to [:edit, @parent, page: 'audience_collections']
  end

  private
  def set_audience_collection
    @audience_collection = @parent.audience_collection
  end

  def audience_collection_params
    params.require(:audience_collection).permit(*policy(@audience_collection || AudienceCollection).permitted_attributes)
  end

  def pundit_authorize
    authorize( @audience_collection || AudienceCollection )
  end

end
