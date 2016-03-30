class EventsController < ApplicationController
  skip_after_action :verify_policy_scoped

  def index
    authorize Event

    respond_to do |format|
      format.html do
      end
      format.json do
        @events = policy_scope(Event).scoped
        @events = @events.future_events unless params[:all]
        @events = @events.limit(params[:limit]) if params[:limit]
        @events = @events.where(id: params[:id]) if params[:id]
        # index.json.jbuilder
      end
    end
  end

  def new
    @event = new_event_from_params
    authorize @event
  end

  def create
    @event = new_event_from_params
    authorize @event

    respond_to do |format|
      format.html do
        if @event.save
          flash[:notice] = "'#{@event.title}' created."
          redirect_to edit_event_path @event
        else
          render :new
        end
      end
      format.json do
        if @event.save
          render json: {success: true}
        else
          render json: {success: false, errors: @event.errors.full_messages}
        end
      end
    end
  end

  def show
    @event = Event.find(params[:id])
    authorize @event

    respond_to do |format|
      format.html do
        redirect_to [:edit, @event]
      end
      format.json do
        # show.json.jbuilder
      end
    end
  end

  def edit
    @event = Event.find(params[:id])
    authorize @event
  end

  def update
    @event = Event.find(params[:id])
    authorize @event

    respond_to do |format|
      format.html do
        if @event.update_attributes(event_params)
          flash[:notice] = "'#{@event.title}' updated."
          redirect_to edit_event_path @event
        else
          render :edit
        end
      end
      format.json do
        if @event.update_attributes(event_params)
          render json: {success: true}
        else
          render json: {success: false, errors: @event.errors.full_messages}
        end
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(*policy(@event || Event).permitted_attributes)
  end

  def new_event_from_params
    if params[:event]
      Event.new(event_params)
    else
      Event.new
    end
  end

end
