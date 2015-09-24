module RouteHelper
  def source_path(source)
    Settings.external_routes.send(source.class.to_s.underscore) + "/#{source.id}" if source.present?
  end
end
