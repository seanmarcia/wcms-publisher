module FormHelper
  def permitted_form_for(object, options = {}, &block)
    options[:builder] = PermittedFormBuilder
    form_for(object, options, &block)
  end

  def divider(text=nil)
    content_tag :div, class: 'divider' do
      content_tag(:div, '', class: 'line') +
      if text.present?
        content_tag(:div, class: 'box_wrapper') do
          content_tag(:div, text, class: 'box')
        end
      else
        ''
      end
    end
  end

end
