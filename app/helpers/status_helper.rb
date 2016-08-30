module StatusHelper
  def status_for(item)
    label_class = class_partial_for(item.aasm_state)

    content_tag :span, item.aasm_state.titleize, class: "label label-#{label_class}"
  end

  def class_partial_for(state)
    case state
    when 'published' then 'success'
    when 'archived' then 'warning'
    when 'ready_for_review' then 'info'
    else 'default'
    end
  end
end
