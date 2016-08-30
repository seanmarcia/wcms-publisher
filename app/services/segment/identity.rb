module Segment
  class Identity
    attr_reader :id, :traits

    def initialize(user)
      raise "Segment::Identity -- Missing required segment_id value. Make sure to set one first." if user.tracking_id.blank?
      raise "Segment::Identity -- Missing required primary email. Make sure to set one first." if user.email.blank?
      @user = user
      @id = user.tracking_id
    end

    def traits
      {
        email: @user.email,
        name: @user.name,
        first_name: @user.first_name,
        last_name: @user.last_name,
        affiliations: @user.affiliations.join(','),
        wcms_roles: wcms_roles,
        wcms_events: event_count,
        wcms_pages: pages_count
      }
    end

    private

    def wcms_roles
      roles = []
      roles += @user.roles
      roles += [:public_bio] if @user.has_published_bio?
      roles += site_roles
      roles.join(', ')
    end

    # returns an array of strings. 
    # Example: ['site_event_publisher', 'site_admin']
    def site_roles
      roles = Site.by_actor(@user).collect {|s| s.permissions.by_actor(@user).pluck(:ability)}.flatten.uniq
      roles.map {|r| "site_#{r}"}
    end

    def event_count
      _ids = Event.with_permission_to(:edit, @user).pluck(:id)
      _ids += Event.where(user_id: @user.id).pluck(:id)
      _ids.uniq.compact.count
    end

    def pages_count
      _ids = PageEdition.with_permission_to(:edit, @user).pluck(:id)
      _ids += PageEdition.where(user_id: @user.id).pluck(:id)
      _ids.uniq.compact.count
    end
  end
end
