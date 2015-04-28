module ApplicationHelper

  def profile_page_path
    page = (params[:page] || 'profile').parameterize('_')

    if File.exists? Rails.root.join('app', 'views', controller_name, 'profile_pages', "_#{page}.html.slim")
      "#{controller_name}/profile_pages/#{page}"
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
