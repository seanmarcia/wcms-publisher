class LinksController < ApplicationController
  def destroy
    if @parent
      @link = @parent.links.find(params[:id])
      authorize @link
      @link.destroy
    end
    redirect_to :back
  end
end
