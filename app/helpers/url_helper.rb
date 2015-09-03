module UrlHelper

  def set_destination(string)
    if uri?(string)
      string
    else
      "#{@page_edition.site.url}#{string}"
    end
  end

  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end
end
