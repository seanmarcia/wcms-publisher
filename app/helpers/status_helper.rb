module StatusHelper
  def status_for(item)
    status =
      if item.published?
        ["success", "Published"]
      elsif item.archived?
        ["warning", "Archived"]
      elsif item.request_review?
        ["info", "Up for Review"]
      else
        ["default", "Draft"]
      end

    content_tag :span, status.last, class: "label label-#{status.first}"
  end
end
