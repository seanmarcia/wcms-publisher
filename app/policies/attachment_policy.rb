class AttachmentPolicy < PermissionsPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || page_editor?
  end
  alias :create? :index?
  alias :edit? :index?
  alias :update? :index?
  alias :destroy? :index?

  def permitted_attributes
    [:attachment, :attachment_cache, :name, :attachable_type, :remote_attachment_url, :attachable_id, :modifier_id, :metadata]
  end
end
