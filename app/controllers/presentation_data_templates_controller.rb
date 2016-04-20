class PresentationDataTemplatesController < ApplicationController
  before_filter :new_presentation_data_template_from_params, only: [:new, :create]
  before_filter :set_presentation_data_template, only: [:show, :edit, :update, :destroy]
  before_filter :pundit_authorize

  def index
    @presentation_data_templates = policy_scope(PresentationDataTemplate).custom_search(params[:q]).asc(:title).page(params[:page]).per(15)
  end

  def show
    redirect_to edit_presentation_data_template_path(@presentation_data_template)
  end

  def new
  end

  def create
    if @presentation_data_template.save
      flash[:info] = "Presentation Data Template was created."
      redirect_to edit_presentation_data_template_path @presentation_data_template
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @presentation_data_template.update_attributes(presentation_data_template_params)
      flash[:info] = "Presentation Data Template changes were saved."
      redirect_to edit_presentation_data_template_path(@presentation_data_template, page: params[:page])
    else
      render :edit
    end
  end

  private
  def new_presentation_data_template_from_params
    @presentation_data_template = PresentationDataTemplate.new(presentation_data_template_params)
  end

  def presentation_data_template_params
    permitted_params(:presentation_data_template)
  end

  def set_presentation_data_template
    @presentation_data_template = PresentationDataTemplate.find(params[:id]) if params[:id]
    @page_name = @presentation_data_template.try(:title)
  end

  def pundit_authorize
    authorize (@presentation_data_template || PresentationDataTemplate)
  end
end
