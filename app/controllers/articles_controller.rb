class ArticlesController < ApplicationController
  include SetSiteCategories
  include IsWorkflow

  before_filter :set_article, only: [:show, :edit, :update, :destroy]
  before_filter :new_article_from_params, only: [:new, :create]
  before_filter :add_people, only: [:create, :update]
  before_filter :pundit_authorize
  before_filter :set_categories_for_article, except: [:index, :show]
  after_filter :push_to_ws, only: [:update, :create]
  respond_to :html, :json

  def index
    authorize Article
    @articles = policy_scope(Article)
    # This returns mongoid::none if you aren't authorized to scope which errors when you try to call @articles.anything so
    # we check and make sure that it actually has value
    unless @articles.none?
      @available_sites = Site.in(id: @articles.distinct(:site_id)).asc(:title)
      @available_topics = @articles.distinct(:topics).sort_by{|a| a.downcase}
      @available_categories = SiteCategory.in(id: @articles.distinct(:site_category_ids)).asc(:title)
      @available_authors = Person.in(id: @articles.distinct(:author_ids)).asc(:name)
      @available_departments = Department.in(id: @articles.distinct(:department_ids)).asc(:name)

      @articles = @articles.custom_search(params[:q]) if params[:q]
      @articles = @articles.by_status(params[:status]) if params[:status]
      @articles = @articles.by_site(params[:site]) if params[:site]
      @articles = @articles.by_topic(params[:topic]) if params[:topic]
      @articles = @articles.by_category(params[:category]) if params[:category]
      @articles = @articles.by_author(params[:author]) if params[:author]
      @articles = @articles.by_department(params[:department]) if params[:department]
      @articles = @articles.featured if params[:featured]
    end

    @articles = @articles.desc(:publish_at).page(params[:page]).per(25)
  end

  def show
    redirect_to edit_article_path @article
  end

  def new
  end

  def create
    author = Person.where(biola_email: params[:a]).first
    @article.user = current_user if current_user.present?
    authorize @article
    set_state @article

    respond_to do |format|
      format.html do
        if @article.save
          @article.image = params[:image] if params[:image]

          flash[:notice] = "#{@article.title} created. You may need to refresh the page to see all the changes."
          redirect_to edit_article_path(@article, page: params[:page])
        else
          render :new
        end
      end
      format.json do
        if @article.save
          render json: {success: true}
        else
          render json: {success: false, errors: @article.errors.full_messages}
        end
      end
    end
  end

  def edit
  end

  def update
    if params[:gallery_photos].present?
      @upload_response = []
      add_gallery_photos
      if @upload_response.include? false
        flash[:warning] = "One or more of the files failed to upload because they are not recognized as images."
      end
      redirect_to edit_article_path @article, page: params[:page]
    else
      @article.image = params[:image] if params[:image]
      set_state(@article)
      @article.related_object_tags = params[:related_objects_string].to_s.split('|').map(&:strip) if params[:related_objects_string]
      @article.site_categories = []
      if @article.update article_params
        flash[:notice] = "#{@article.title} updated. You may need to refresh the page to see all the changes."
        redirect_to edit_article_path(@article, page: params[:page])
      else
        render :edit
      end
    end
  end

  def destroy
    if !@article.published? && @article.destroy
      flash[:notice] = "#{@article} deleted."
      redirect_to articles_path
    else
      flash[:notice] = "#{@article} cannot be deleted."
      redirect_to article_path @article
    end
  end

  def search
    respond_with Person.custom_search(params[:query] || params[:term]).limit(5).to_json(only: ["biola_email", "first_name", "last_name", "affiliations", "biola_photo_url", "department"])
  end

  def update_from_ws
    # faiw = FireArticleImportWorker.new.manual_sync
    # flash[:info] = "Articles have been updated from Web Services." if faiw == true
    flash[:info] = 'This importer has been disabled'

    redirect_to articles_path
  end

  protected
  def add_gallery_photos
    if params[:gallery_photos]
      Array(params[:gallery_photos]).each do |gallery_photo|
        @upload_response << @article.gallery_photos.new(photo: gallery_photo.last[:photo], caption: gallery_photo.last[:caption]).save
      end
    end
  end

  def add_people
    related_people = []
    if params[:rp]
      params[:rp].split('|').each do |rp|
        related_people << Person.where(biola_email: rp).first
      end

      @log_related_people = {}
      if @article.related_people != related_people
        @log_related_people = {"related_person_ids" => [@article.related_people.try(:map, &:name).join(', ').presence, related_people.map(&:name).join(', ')]}
      end

      authors = Person.where(biola_email: {'$in' => params[:a].to_s.split('|')})
      @article.related_people = related_people
      @article.authors = authors
      # # saving here to maintain author order of  the author array
      @article.save
    end
  end

  def new_article_from_params
    if params[:article]
      @article = Article.new(article_params)
    else
      @article = Article.new
    end
  end

  def article_params
    if params[:article]
      params[:article][:meta_keywords] = params[:article][:meta_keywords].split(',') unless params[:article][:meta_keywords].nil?
      # We're not using `require` here because it could be blanak when updating presentation data
      ActionController::Parameters.new(params[:article]).permit(*policy(@article || Article).permitted_attributes).tap do |whitelisted|
        # You have to whitelist the hash this way, see https://github.com/rails/rails/issues/9454
        whitelisted[:presentation_data] = params[:pdata] if params[:pdata].present?
      end
    else
      {}
    end
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def pundit_authorize
    authorize @article || Article
  end

  def push_to_ws
    WsExportWorker.perform_in(1, @article.id, 'Article') if exportable?
  end

  def exportable?
    @article.previous_changes.present? && @article.published? && Settings.ws_syncable_sites.include?(@article.site.title)
  end

  def set_categories_for_article
    set_categories('Article')
  end
end
