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
    respond_to do |format|
      format.html do
        # @page_editions will get loaded in via ajax
        @sites = policy_scope(Site).asc(:title).map {|site| {id: site.id.to_s, title: site.title, url: site.url}}
      end
      format.json do
        @page_editions = policy_scope(PageEdition).where(site_id: params[:site_id]).asc(:slug)
        @page_editions = @page_editions.where(id: params[:id]) if params[:id]
        @page_editions = @page_editions.limit(params[:limit]) if params[:limit]
        @page_editions = @page_editions.skip(params[:offset]) if params[:offset]
        @page_editions = @page_editions.where(parent_page_id: params[:parent_page_id].presence) unless params[:all]
        # index.json.jbuilder
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        redirect_to [:edit, @page_edition]
      end
      format.json do
        # show.json.jbuilder
      end
    end
  end

  def new
    @page_edition = PageEdition.new
    @page_edition.site_id = params[:site_id]
    @page_edition.parent_page_id = params[:parent_page_id]
    if @page_edition.parent_page
      @page_edition.site_id = @page_edition.parent_page.site_id # ensure site id matches parent
      @page_edition.slug = @page_edition.parent_page.slug + '/'
      @page_edition.source = @page_edition.parent_page.source
      @page_edition.departments = @page_edition.parent_page.departments
      @page_edition.topics = @page_edition.parent_page.topics
      @page_edition.keywords = @page_edition.parent_page.keywords
    end
  end

  def create
    if @error
      flash[:notice] = @error
    elsif @page_edition.save
      set_author
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

  # On create if an author doesnt already have permissions to edit create a permission
  #  allowing them to edit this page.
  def set_author
    unless policy(@page_edition).page_editor?
      author = Permission.new(
                      actor_id: current_user.id,
                      actor_type: 'User',
                      ability: :edit,
                      modifier_id: current_user.id
                    )
      # Pushing the author onto the permissions array in case set author is
      #  ever called after create and permissions already exist.
      @page_edition.permissions << author
      @page_edition.save
    end
  end

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
