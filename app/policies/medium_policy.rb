class MediumPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin?
  end
  alias :show? :index?

  def create?
    user.admin?
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?
  alias :destroy? :create?

  def permitted_attributes
    attrs = [:title, :subtitle, :metadata, :thumbnail, :video_placeholder_image, :related_object_tags_string,
             :remove_thumbnail, :remove_video_placeholder_image]

    attrs += [media_resources: []]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :activity_logs, :permissions
      user.admin? || user.developer?
    else
      false
    end
  end
end
