class ImportantDatesController < ApplicationController

  before_filter :set_important_date, only: [:show, :edit, :update]
  before_filter :new_important_date_from_params, only: [:new, :create]
  before_filter :pundit_authorize

  def index
    @important_dates = policy_scope(ImportantDate)
    @important_dates = @important_dates.desc(:title).page(params[:page]).per(25)
  end

  def show
    redirect_to [:edit, @important_date]
  end

  def new
  end

  def create
    if @important_date.save
      redirect_to [:edit, @important_date]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @important_date.update_attributes(important_date_params)
      redirect_to [:edit, @important_date]
    else
      render :edit
    end
  end

  private

  def new_important_date_from_params
    if params[:important_date]
      @important_date = ImportantDate.new(important_date_params)
    else
      @important_date = ImportantDate.new
    end
  end

  def important_date_params
    params[:important_date][:categories] = params[:important_date][:categories].split(',')
    params[:important_date][:audiences] = params[:important_date][:audiences].split(',')
    params.require(:important_date).permit(*policy(@important_date || ImportantDate).permitted_attributes)
  end

  def set_important_date
    @important_date = ImportantDate.find(params[:id]) if params[:id]
    @page_name = @important_date.try(:title)
  end

  def pundit_authorize
    authorize (@important_date || ImportantDate)
  end

end
