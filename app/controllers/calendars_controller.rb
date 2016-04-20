class CalendarsController < ApplicationController
  before_filter :set_calendar, only: [:show, :edit, :update]
  before_filter :new_calendar_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @calendars = policy_scope(Calendar)

    unless @calendars.none?
      @available_tags = @calendars.distinct(:tags).flatten.uniq

      @calendars = @calendars.custom_search(params[:q]) if params[:q]
      @calendars = @calendars.by_tag(params[:tag]) if params[:tag]
    end

    @calendars = @calendars.asc(:start_date).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @calendar]
  end

  def new
  end

  def create
    if @calendar.save
      flash[:notice] = "'#{@calendar.title}' created."
      redirect_to [:edit, @calendar]
    else
      render :new
    end
  end

  def edit
    build_section
  end

  def update
    if params[:calendar][:calendar_sections]
      update_calendar_sections
    else
      normal_update
    end
  end

  private

  def update_calendar_sections
    params[:calendar][:calendar_sections].each do |k,v|
      section = @calendar.calendar_sections.where(id: k).first || @calendar.calendar_sections.new
      if v[:_destroy] == "1"
        section.destroy
      else
        section.update_attributes(v.permit(*policy(section).permitted_attributes))
      end
    end

    redirect_to edit_calendar_path(@calendar, page: params[:page])
  end

  def normal_update
    if @calendar.update_attributes(calendar_params)
      flash[:notice] = "'#{@calendar.title}' updated."
      redirect_to edit_calendar_path(@calendar, page: params[:page])
    else
      render :edit
    end
  end

  def new_calendar_from_params
    @calendar = Calendar.new(calendar_params)
  end

  def calendar_params
    permitted_params(:calendar) do |p|
      p[:tags] = p[:tags].split(',').map(&:strip) if p[:tags]
      p[:meta_keywords] = p[:meta_keywords].split(',').map(&:strip) if p[:meta_keywords]
    end
  end

  def set_calendar
    @calendar = Calendar.find(params[:id]) if params[:id]
    @page_name = @calendar.try(:title)
  end

  def build_section
    @calendar.calendar_sections.new
  end

  def pundit_authorize
    authorize (@calendar || Calendar)
  end

end
