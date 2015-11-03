class API::PageEditionsController < API::ApplicationController

  before_action :set_page_edition
  before_action :pundit_authorize

  def index
    filter_index
    render json: JSONAPI::Serializer.serialize(@page_editions, is_collection: true)
  end

  def show
    render json: JSONAPI::Serializer.serialize(@page_edition)
  end

  private

  def filter_index
    @page_editions = policy_scope(PageEdition).where(site_id: params[:site_id])
    unless (params[:all])
      @page_editions = @page_editions.where(parent_page_id: params[:parent_page_id].presence)
    end
  end

  def set_page_edition
    @page_edition = PageEdition.find(params[:id]) if params[:id]
  end

  def pundit_authorize
    authorize (@page_edition || PageEdition)
  end

end
