class CalendarsController < ApplicationController

  before_filter :set_calendar, only: [:show, :edit, :update]
  before_filter :new_calendar_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @calendars = policy_scope(Calendar)
    @calendars = @calendars.desc(:title).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @calendar]
  end

  def new
  end

  def create
    if @calendar.save
      redirect_to [:edit, @calendar]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @calendar.update_attributes(calendar_params)
      redirect_to [:edit, @calendar]
    else
      render :edit
    end
  end

  private

  def new_calendar_from_params
    if params[:calendar]
      @calendar = Calendar.new(calendar_params)
    else
      @calendar = Calendar.new
    end
  end

  def calendar_params
    params[:calendar][:tags] = params[:calendar][:tags].split(',')
    params.require(:calendar).permit(*policy(@calendar || Calendar).permitted_attributes)
  end

  def set_calendar
    @calendar = Calendar.find(params[:id]) if params[:id]
    @page_name = @calendar.try(:title)
  end

  def pundit_authorize
    authorize (@calendar || Calendar)
  end

end
