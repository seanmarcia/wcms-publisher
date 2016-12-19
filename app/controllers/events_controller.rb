class EventsController < ApplicationController
  include SetSiteCategories
  include IsWorkflow

  skip_after_action :verify_policy_scoped
  before_filter :set_categories_for_event, except: [:index, :show]

  def index
    authorize Event
    @events = policy_scope(Event).scoped

    respond_to do |format|
      format.html do
        @available_sites = Site.where(has_events: true).asc(:title)
        @available_departments = Department.in(id: @events.distinct(:department_ids)).asc(:title)

        @events = @events.custom_search(params[:q]) if params[:q]
        @events = @events.order(params[:sort] + ' ' + params[:direction]) if params[:sort]
        @events = @events.by_status(params[:status]) if params[:status]
        @events = @events.by_site(params[:site]) if params[:site]
        @events = @events.by_department(params[:department]) if params[:department]
        @events = @events.future if params[:future]
        @events = @events.where(imported: true) if params[:imported]
        @events = @events.desc('event_occurrences.start_time').page(params[:page]).per(25)
      end
      format.json do
        @events = @events.future unless params[:all]
        @events = @events.limit(params[:limit]) if params[:limit]
        @events = @events.where(id: params[:id]) if params[:id]
        # index.json.jbuilder
      end
    end
  end

  def new
    @event = new_event_from_params
    @event.user = current_user if current_user.present?
    authorize @event
  end

  def create
    @event = new_event_from_params
    @event.user ||= current_user if current_user.present?
    authorize @event
    set_state(@event)

    respond_to do |format|
      format.html do
        if @event.save
          broadcast(:track!, current_user, :created, @event) if current_user
          flash[:notice] = "'#{@event.title}' created."
          redirect_to edit_event_path @event, page: params[:page]
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
    @event.user ||= current_user if current_user.present?
    authorize @event
    set_state(@event)
    add_links

    respond_to do |format|
      format.html do
        if @event.update_attributes(event_params)
          broadcast(:track!, current_user, :updated, @event) if current_user
          flash[:notice] = "'#{@event.title}' updated."
          redirect_to edit_event_path @event, page: params[:page]
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

  def duplicate
    @event = Event.find(params[:id])
    authorize @event
    duplicated_event = @event.clone

    if duplicated_event
      @event = duplicated_event
      broadcast(:track!, current_user, :duplicated, @event) if current_user
      render :new
    else
      flash[:error] = "Something went wrong, please try again."
      redirect_to @event
    end
  end

  private

  def event_params
    permitted_params(:event)
  end

  def new_event_from_params
    Event.new(event_params)
  end

  def add_links
    if params[:links]
      upload_response = []
      Array(params[:links]).each do |link|
        upload_response << @event.links.new(title: link.last[:title], url: link.last[:url]).save
      end
      if upload_response == false
        flash[:warning] = 'One or more of the links failed to add. Please try again.'
      end
    end
  end

  def new_address
    @event.address = Address.new if @event.address.nil?
  end

  def set_categories_for_event
    set_categories('Event')
  end

end
