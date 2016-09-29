# example usage: IntercomPolicy.new(current_user, request).hide_messenger?
class IntercomPolicy
  SHOW_FOR_ALL_USERS = true
  SHOW_FOR_VISITORS = false
  
  def initialize(user, request)
    @user = user
    @request = request
  end

  def hide_messenger?
    !show_messenger?
  end

  private

  attr_reader :user, :request

  def show_messenger?
    decision = 
      (show_for_user? && page_not_blacklisted?) || 
      (page_whitelisted? && page_not_blacklisted?)
    
    Rails.logger.info "IntercomPolicy: INFO - #{decision ? 'Showing' : 'Hiding'} Intercom Messenger for user_id=#{user.try(:id).to_s}, request_path=#{request.path}"
    decision
  end

  ## Decision methods
  def show_for_user?
    SHOW_FOR_ALL_USERS || 
    SHOW_FOR_VISITORS ||
    (user.try(:affiliations) & allowed_affiliations).present?
  end

  def page_not_blacklisted?
    !page_is_blacklisted?
  end

  def page_is_blacklisted?
    (blocked_paths.include? request.path) || 
    matches_any_blocked_paths_regex?
  end

  def matches_any_blocked_paths_regex?
    matches = []
    blocked_paths_regex.each do |rex| 
      matches << request.path.match(/#{rex}/)
    end
    # compact the array to remove nils (or non-matches)
    matches.compact.present?
  end

  def page_whitelisted?
    allowed_paths.include? request.path
  end

  ## Settings methods
  def allowed_paths
    []
  end

  def blocked_paths
    []
  end

  def blocked_paths_regex
    []
  end

  def allowed_affiliations
    []
  end

  def allowed_roles
    []
  end
end
