class AttachmentPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.developer?
  end
  alias :create? :index?
  alias :destroy? :index?

  def permitted_attributes
    [:attachment, :attachment_cache, :name, :attachable_type, :remote_attachment_url, :attachable_id, :metadata]
  end
end
