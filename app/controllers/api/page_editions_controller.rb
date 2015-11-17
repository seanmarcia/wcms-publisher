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
    @page_editions = policy_scope(PageEdition).where(site_id: params[:site_id]).asc(:slug)
    @page_editions = @page_editions.where(id: params[:id]) if params[:id]
    @page_editions = @page_editions.limit(params[:limit]) if params[:limit]
    @page_editions = @page_editions.skip(params[:offset]) if params[:offset]
    @page_editions = @page_editions.where(parent_page_id: params[:parent_page_id].presence) unless params[:all]
  end

  def set_page_edition
    @page_edition = PageEdition.find(params[:id]) if params[:id]
  end

  def pundit_authorize
    authorize (@page_edition || PageEdition)
  end

end
