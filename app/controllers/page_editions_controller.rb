class PageEditionsController < ApplicationController
  include SetSiteCategories
  include SetModifier

  before_filter :set_page_edition, only: [:show, :edit, :update, :destroy, :create_tag]
  before_filter :new_page_edition_from_params, only: [:new, :create]
  before_filter :set_categories_for_page_edition
  before_filter :set_source, only: [:create, :update]
  before_filter :pundit_authorize
  before_filter :new_audience_collection, only: [:edit, :update, :new, :create]

  def index
    @site = policy_scope(Site).find(params[:sid]) if params[:sid]
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
      child_pages.each{|child| child.update_attributes({parent_page_id: nil})} if child_pages.present?
      flash[:info] = "Page has been successfully removed. <a href=/wcms_components/changes/#{@page_edition.history_tracks.last.id}/undo_destroy>Undo</a>"
    else
      flash[:error] = "Something went wrong. Please try again."
    end
    redirect_to page_editions_path
  end

  def create_tag
    if @page_edition.slug.blank?
      flash[:error] = 'You need to set a slug before creating a tag.'
    elsif tag = Tag.create_from_object(@page_edition, current_user: current_user, class_slug: 'page_edition')
      if @page_edition.update_attributes({my_object_tag: tag.tag})
        flash[:info] = 'Tag Created.'
      else
        flash[:error] = 'Tag was created but it could not be added to this object.'
      end
    else
      flash[:error] = 'There was a problem creating the tag. Make sure one does not already exist with this slug.'
    end
    redirect_to edit_page_edition_path(@page_edition, page: 'relationships')
  end

  def view_topics
    topics = PageEdition.distinct(:topics)
    if params[:q].present?
      q = Regexp.new(params[:q].to_s, Regexp::IGNORECASE)
      topics = topics.select{|g| g[q]} || []
    end
    render json: topics.map{|ct| [topic: ct]}.flatten
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
    # Normally this would need to set user for the logging but seeing as it is called imediatly
    #  after a save it will create another history_track using the last known modifier.
    #  If this method is ever called outside of one of the crud actions it will need to set the user.
    if params[:published].present? && !@page_edition.published?
      @page_edition.publish!
    elsif params[:archived].present? && !@page_edition.archived?
      @page_edition.archive!
    end
  end

  def set_categories_for_page_edition
    set_categories('Page Edition')
  end
end
