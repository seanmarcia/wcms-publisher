class MenuPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.developer?
  end
  alias :show? :index?

  def create?
    user.admin? || user.developer?
  end
  alias :new? :create?
  alias :update? :create?
  alias :edit? :create?
  alias :destroy? :create?

  def permitted_attributes
    attrs = [:title, :url, :slug, :site_id, :menu_links_json, page_edition_ids: []]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :form
      true
    when :activity_logs, :menu_links, :permissions
      user.admin? || user.developer?
    else
      false
    end
  end
end
