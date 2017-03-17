class ArticlePolicy < PermissionsPolicy
  class Scope < PermissionsPolicy
    attr_reader :user, :scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if article_admin? || user.has_role?(:article_viewer)
        scope.all
      elsif article_author?
        scope.in(site_id: Site.with_any_permission_to([:article_publisher,
                                                       :article_editor,
                                                       :article_author], user).pluck(:id))
      else
        scope.none
      end
    end
  end

  def create?
    article_author?
  end
  alias new? create?
  alias search? create?

  def index?
    user.has_role?(:employee) || article_viewer?
  end

  def update_from_ws?
    article_admin?
  end

  def edit?
    site_article_author?(record.site)
  end
  alias show? edit?
  alias destroy? edit?

  def update?
    !record.imported? && (site_article_editor?(record.site) || record.user == user)
  end

  def publish?
    article_publisher?
  end

  def publishable_sites
    if user.admin?
      Site.all
    else
      Site.with_permission_to(:article_publisher, user)
    end
  end

  def editable_sites
    publishable_sites.presence ||
      Site.with_permission_to(:article_editor, user)
  end

  def authorable_sites
    editable_sites.presence ||
      Site.with_permission_to(:article_author, user)
  end

  def permitted_aasm_events
    if publish?
      [:submit_for_review, :return_to_draft, :approve, :unapprove, :publish, :archive]
    elsif create?
      [:submit_for_review]
    else
      []
    end
  end

  def permitted_attributes
    pa = []
    # if its new than check that its an Article, otherwise check to see if its origin is wcms
    #  through the update? method
    # If the record is a draft it can be edited but if its in the review process only editors and
    #  above can edit it
    if record == Article ||
       ((record.try(:new_record?) || update?) && (record.draft? || article_editor?))

      pa << [:title, :subtitle, :body, :topics_string, :teaser, :article_template,
             :publish_sidekiq_id, :archive_sidekiq_id, :author_ids, :slug, :related_object_tags,
             :image, :crop_x, :crop_y, :crop_w, :crop_h, :ws_id, :ws_source, :ws_author, :user_id,
             :press_release, :external_url,
             department_ids: [], audience: [], gallery_photos: [], site_category_ids: [],
             related_person_ids: []]

      pa << :site_id if record == Article || record.draft?
      pa << [:publish_at, :archive_at, :featured] if article_publisher?
      pa << [:presentation_data_json, :presentation_data_template_id] if user.admin?
      pa |= SEO_FIELDS if user.admin? # Inherited from ApplicationPolicy
    end
    pa.flatten
  end

  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form, :logs
      article_editor? || user.try(:admin?)
    when :gallery_photos
      article_editor? || article_admin?
    when :seo
      article_admin?
    when :design, :presentation_data
      user.admin? || user.has_role?(:designer)
    else
      false
    end
  end
end
