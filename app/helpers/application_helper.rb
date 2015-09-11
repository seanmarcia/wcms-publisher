module ApplicationHelper

  def page_title
    title = "WCMS"
    title += " (#{Rails.env})" unless Rails.env == "production"
    title = "#{controller_name.titleize} | #{title}" if controller_name.present?
    title = "#{@page_name} | #{title}" if @page_name.present?
    title
  end

  def form_page_path
    page = (params[:page] || 'form').parameterize('_')

    if File.exists? Rails.root.join('app', 'views', controller_name, 'edit_partials', "_#{page}.html.slim")
      "#{controller_name}/edit_partials/#{page}"
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
