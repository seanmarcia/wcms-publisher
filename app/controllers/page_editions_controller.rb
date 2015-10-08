class PageEditionsController < ApplicationController
  include ActivityLoggable
  include SetSiteCategories

  before_filter :set_page_edition, only: [:show, :edit, :update, :destroy, :create_tag]
  before_filter :new_page_edition_from_params, only: [:new, :create]
  before_filter :set_categories_for_page_edition
  before_filter :set_source, only: [:create, :update]
  before_filter :pundit_authorize
  before_filter :new_audience_collection, only: [:edit, :update, :new, :create]

  def index
    @page_editions = policy_scope(PageEdition)

    unless @page_editions.none?
      # Filter Values
      @available_sites = Site.in(id: @page_editions.distinct(:site_id)).asc(:title)
      @available_page_templates = @page_editions.distinct(:page_template).sort_by{|a| a.downcase }
      @redirected_pages = @page_editions.redirected

      # Filter Results
      @page_editions = @page_editions.custom_search(params[:q]) if params[:q]
      @page_editions = @page_editions.redirected if params[:redirected]
      @page_editions = @page_editions.by_status(params[:status]) if params[:status]
      @page_editions = @page_editions.by_site(params[:site]) if params[:site]
      @page_editions = @page_editions.by_last_change(params[:last_change]) if params[:last_change]
      @page_editions = @page_editions.by_page_template(params[:page_template]) if params[:page_template]
    end

    @page_editions = @page_editions.asc(:slug).page(params[:page]).per(25)
  end

  def show
    @page_edition = PageEdition.find(params[:id])
    redirect_to [:edit, @page_edition]
  end

  def new
    @page_edition = PageEdition.new
    @page_edition.site_id = params[:site_id]
    @page_edition.parent_page_id = params[:parent_page_id]
    if @page_edition.parent_page
      @page_edition.slug ||= @page_edition.parent_page.slug + '/'
    end
  end

  def create
    if @error
      flash[:notice] = @error
    elsif @page_edition.save
      log_activity(@page_edition.previous_changes, parent: @page_edition)
      update_state
      flash[:notice] = "'#{@page_edition.title}' created."
      redirect_to [:edit, @page_edition]
    else
      render :new
    end
  end

  def edit
    @page_edition = PageEdition.find(params[:id])
  end

  def update
    if @error
      flash[:warning] = @error
      render :edit
    elsif @page_edition.update_attributes(page_edition_params)
      log_activity(@page_edition.previous_changes, parent: @page_edition, child: @page_edition.audience_collection.previous_changes)
      update_state
      flash[:notice] = "'#{@page_edition.title}' updated."
      redirect_to edit_page_edition_path @page_edition, page: params[:page], choose_template: params[:choose_template]
    else
      render :edit
    end
  end

  def destroy
    child_pages = @page_edition.child_pages

    if @page_edition.destroy
      child_pages.each{|child| child.update_attributes(parent_page_id: nil)} if child_pages.present?

      flash[:info] = "Page has been successfully removed."
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to page_editions_path
  end

  def create_tag
    if @page_edition.slug.blank?
      flash[:error] = 'You need to set a slug before creating a tag.'
    elsif tag = Tag.create_from_object(@page_edition, class_slug: 'page_edition')
      if @page_edition.update_attribute(:my_object_tag, tag.tag)
        flash[:info] = 'Tag Created.'
      else
        flash[:error] = 'Tag was created but it could not be added to this object.'
      end
    else
      flash[:error] = 'There was a problem creating the tag. Make sure one does not already exist with this slug.'
    end
    redirect_to edit_page_edition_path(@page_edition, page: 'relationships')
  end

  private

  def set_source
    if params[:source_change].present?
      case params[:source_type]
      when 'academic_subject'
        source = AcademicSubject.where(id: params[:academic_subject]).first
      when 'academic_program'
        source = AcademicProgram.where(id: params[:academic_program]).first
      when 'concentration'
        source = Concentration.where(id: params[:concentration]).first
      when 'department'
        source = Department.where(id: params[:department]).first
      when 'event'
        source = Event.where(id: params[:event]).first
      when 'group'
        source = Group.where(id: params[:group]).first
      else
        source = nil
      end
      if params[:source_type].present? && source.nil?
        @error = "A #{params[:source_type].titleize} needs to be selected."
      end
      @page_edition.source = source
    end
  end

  def new_audience_collection
    @page_edition.audience_collection = AudienceCollection.new if @page_edition.audience_collection.nil?
  end

  def new_page_edition_from_params
    if params[:page_edition]
      @page_edition = PageEdition.new(page_edition_params)
    else
      @page_edition = PageEdition.new
    end
  end

  def page_edition_params
    if params[:page_edition] && params[:page_edition][:meta_keywords]
      params[:page_edition][:meta_keywords] = params[:page_edition][:meta_keywords].split(',')
    end
    params.require(:page_edition).permit(*policy(@page_edition || PageEdition).permitted_attributes)
  end

  def set_page_edition
    @page_edition = PageEdition.find(params[:id]) if params[:id]
    @page_name = @page_edition.try(:title)
  end

  def pundit_authorize
    authorize (@page_edition || PageEdition)
  end

  def update_state
    if params[:published].present? && !@page_edition.published?
      @page_edition.publish!
      log_activity(@page_edition.previous_changes, parent: @page_edition)
    elsif params[:archived].present? && !@page_edition.archived?
      @page_edition.archive!
      log_activity(@page_edition.previous_changes, parent: @page_edition)
    end
  end

  def set_categories_for_page_edition
    set_categories('Page Edition')
  end
end
