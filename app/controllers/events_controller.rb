class EventsController < ApplicationController
  include SetSiteCategories

  skip_after_action :verify_policy_scoped
  before_filter :set_categories_for_event, except: [:index, :show]

  def index
    authorize Event
    @events = policy_scope(Event).scoped

    respond_to do |format|
      format.html do
        @available_sites = Site.where(has_events: true).asc(:title)
        @available_departments = Department.in(id: @events.distinct(:department_ids)).asc(:name)
        @request_review_count = @events.request_review.count

        @events = @events.custom_search(params[:q]) if params[:q]
        @events = @events.by_status(params[:status]) if params[:status]
        @events = @events.by_site(params[:site]) if params[:site]
        @events = @events.by_department(params[:department]) if params[:department]
        @events = @events.request_review if params[:request_review]
        @events = @events.desc(:publish_at).page(params[:page]).per(25)
      end
      format.json do
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
    set_status
    add_links
    # @event.site_categories = []

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

  def duplicate
    duplicated_event = @event.clone
    if duplicated_event
      log_activity(duplicated_event.previous_changes, parent: duplicated_event)

      flash[:info] = "#{@event} duplicated."
      @event = duplicated_event
      render :new
    else
      flash[:error] = "Something went wrong, please try again."
      redirect_to event_path
    end
  end

  private

  def event_params
    permitted_params(:event)
  end

  def new_event_from_params
    if params[:event]
      Event.new(event_params)
    else
      Event.new
    end
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

  def set_status
    if @event.valid?
      if params[:commit] == "Submit for Review"
        @event.submit_for_review
      elsif params[:commit] == "Return to Draft" && policy(@event).publish?
        @event.return_to_draft
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
