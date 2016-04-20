class EventCollectionsController < ApplicationController

  def index
    authorize EventCollection
    @event_collections = policy_scope(EventCollection).scoped
    @event_collections = @event_collections.custom_search(params[:q]) if params[:q]
    @event_collections = @event_collections.desc(:title).page(params[:page]).per(50)
  end

  def show
    @event_collection = EventCollection.find(params[:id])
    authorize(@event_collection)
    redirect_to [:edit, @event_collection]
  end

  def new
    @event_collection = new_event_collection_from_params
    authorize(@event_collection)
  end

  def create
    @event_collection = new_event_collection_from_params
    authorize(@event_collection)
    if @event_collection.save
      flash[:notice] = "'#{@event_collection.title}' created."
      redirect_to edit_event_collection_path @event_collection
    else
      render :new
    end
  end

  def edit
    @event_collection = EventCollection.find(params[:id])
    authorize(@event_collection)
  end

  def update
    @event_collection = EventCollection.find(params[:id])
    authorize(@event_collection)
    if @event_collection.update_attributes(event_collection_params)
      flash[:notice] = "'#{@event_collection.title}' updated."
      redirect_to edit_event_collection_path @event_collection, page: params[:page]
    else
      render :edit
    end
  end

  private

  def event_collection_params
    permitted_params(:event_collection)
  end

  def new_event_collection_from_params
    if params[:event_collection]
      EventCollection.new(event_collection_params)
    else
      EventCollection.new
    end
  end
end
