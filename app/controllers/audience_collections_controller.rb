class AudienceCollectionsController < ApplicationController
  before_filter :pundit_authorize
  before_filter :set_audience_collection

  def show
  end

  def create
  end

  def update
  end

  def edit
  end

  private
  def set_audience_collection
    @audience_collection = @parent.audience_collection.presence || (@parent.update(audience_collection: AudienceCollection.new); @parent.audience_collection)
  end

  def pundit_authorize
    policy( @audience_collection || AudienceCollection )
  end

end
