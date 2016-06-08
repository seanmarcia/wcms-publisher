module StatusHelper
  def status_for(item)
    label_class = case item.aasm_state
    when 'published' then 'success'
    when 'archived' then 'warning'
    when 'ready_for_review' then 'info'
    else 'default'
    end

    content_tag :span, item.aasm_state.titleize, class: "label label-#{label_class}"
  end
end
