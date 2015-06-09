class PageEditionPolicy < ApplicationPolicy
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
    attrs = [:title, :slug, :site_id, :body, :page_template, attachment_ids: []]
    attrs += [:presentation_data_json, :presentation_data_template_id]
    attrs
  end

  ##### Special non-action permissions
  def can_manage?(attribute)
    case attribute.try(:to_sym)
    when nil, :profile
      true
    when :activity_logs, :permissions, :presentation_data, :attachments
      user.admin? || user.developer?
    else
      false
    end
  end
end
