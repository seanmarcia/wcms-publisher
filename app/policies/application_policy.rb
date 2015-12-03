require 'concerns/policy_permissions'

class ApplicationPolicy
  include PolicyPermissions

  attr_reader :user, :record

  SEO_FIELDS = [:page_title, :meta_description, :meta_robots, {meta_keywords: []}, :canonical_url]

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  ##### Special non-action permissions
  def permitted_attributes
    []
  end

  def can_manage?(attribute)
    false
  end

  def can_change?(parameter)
    flat_permitted_attributes = permitted_attributes.map { |attribute|
      case attribute
      when Hash
        attribute.keys
      else
        attribute
      end
    }.flatten

    flat_permitted_attributes.include? parameter.to_sym
  end

  def cant_change?(parameter)
    !can_change?(parameter)
  end
end
