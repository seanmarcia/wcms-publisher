module ApplicationHelper

  def form_page_path
    page = (params[:page] || 'form').parameterize('_')

    if File.exists? Rails.root.join('app', 'views', controller_name, 'edit_partials', "_#{page}.html.slim")
      "#{controller_name}/edit_partials/#{page}"
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
