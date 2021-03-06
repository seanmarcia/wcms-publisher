class ImportantDatesController < ApplicationController
  before_filter :set_important_date, only: [:show, :edit, :update, :destroy]
  before_filter :new_important_date_from_params, only: [:new, :create]
  before_filter :pundit_authorize
  before_filter :new_audience_collection, only: [:edit, :update, :new, :create]

  def index
    @important_dates = policy_scope(ImportantDate)

    unless @important_dates.none?
      @available_calendars = Calendar.in(id: @important_dates.distinct(:calendar_ids)).asc(:title)
      @available_categories = @important_dates.distinct(:categories).sort_by{|a| a.downcase }
      @available_audiences = @important_dates.distinct(:audiences).sort_by{|a| a.downcase }

      @important_dates = @important_dates.custom_search(params[:q]) if params[:q]
      @important_dates = @important_dates.by_calendar(params[:calendar]) if params[:calendar]
      @important_dates = @important_dates.by_category(params[:category]) if params[:category]
      @important_dates = @important_dates.by_audience(params[:audience]) if params[:audience]
      @important_dates = @important_dates.future_dates if params[:future]
      @important_dates = @important_dates.is_a_deadline if params[:deadline]
      @important_dates = @important_dates.by_last_change(params[:last_change]) if params[:last_change]
    end

    @important_dates = @important_dates.desc(:start_date).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @important_date]
  end

  def new
  end

  def create
    if @important_date.save
      flash[:notice] = "'#{@important_date.title}' created."
      redirect_to [:edit, @important_date]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @important_date.update_attributes(important_date_params)

      flash[:notice] = "'#{@important_date.title}' updated."
      redirect_to edit_important_date_path @important_date, page: params[:page]
    else
      render :edit
    end
  end

  def destroy
    if @important_date.destroy
      flash[:info] = "Important Date has been successfully removed. <a href=/wcms_components/changes/#{@important_date.history_tracks.last.id}/undo_destroy>Undo</a>"
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to important_dates_path
  end

  private

  def new_audience_collection
    @important_date.audience_collection = AudienceCollection.new if @important_date.audience_collection.nil?
  end

  def new_important_date_from_params
    @important_date = ImportantDate.new(important_date_params)
  end

  def important_date_params
    permitted_params(:important_date) do |p|
      p[:categories] = p[:categories].split(',').map(&:strip) if p[:categories]
    end
  end

  def set_important_date
    @important_date = ImportantDate.find(params[:id]) if params[:id]
    @page_name = @important_date.try(:title)
  end

  def pundit_authorize
    authorize(@important_date || ImportantDate)
  end

end
