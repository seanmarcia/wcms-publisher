module PublisherHelper

  def publisher_link(publisher)
    if publisher.class_name
      title = publisher.title || publisher.class_name.titleize.pluralize
      link_to(title, [publisher.class_name.tableize], class: 'list-group-item')
    elsif publisher.url
      link_to(publisher.title, publisher.url, class: 'list-group-item')
    end
  end

  def publisher_first_letter(publisher)
    (publisher.title || publisher.class_name).first.upcase
  end

end
