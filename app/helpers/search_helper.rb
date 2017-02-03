module SearchHelper
  def link_to_param(title, param, value = true, options = {})
    link_to title, params.merge(
      param => (params[param] == value.to_s ? nil : value), page: nil
    ), options
  end

  def link_to_nested_param(title, nested_value, param, value = true, options = {})
    link_to title, params.merge(
      param => (params[param] == value.to_s ? nil : value), tab: nested_value
    ), options
  end

  def nav_list_link(title, param, value = true, options = {})
    return if title.blank?
    css_class = (params[param] == value.to_s ? 'active' : nil)

    content_tag(:li, class: css_class) do
      link_to_param title, param, value, options
    end
  end

  def nested_nav_list_link(title, nested_value, param, value = true)
    css_class = (params[param] == value.to_s ? 'active' : nil)

    content_tag(:li, class: css_class) do
      link_to_nested_param title, nested_value.to_s, param, value
    end
  end

  def blank_nav_list_link(title, param, value = true, options = {})
    css_class = (params[param] ? nil : 'active')

    content_tag(:li, class: css_class) do
      link_to_param title, param, value, options
    end
  end

  def link_to_multi_select_param(title, param, value = true)
    param_value =
      if Array(params[param]).include?(value.to_s)
        Array(params[param]) - [value]
      else
        Array(params[param]) + [value]
      end
    link_to title, params.merge(param => param_value, page: nil)
  end

  def multi_select_nav_list_link(title, param, value = true)
    css_class = (Array(params[param]).include?(value.to_s) ? 'active' : nil)

    content_tag(:li, class: css_class) do
      link_to_multi_select_param title, param, value
    end
  end

  def nav_list_header(title, param)
    close_link =
      if params[param]
        link_to('&times;'.html_safe, params.merge(param => nil), class: 'close pull-right')
      end

    content_tag(:li, class: 'nav-header') do
      title.html_safe + close_link.to_s
    end
  end

  # Nav Pill
  alias_method :nav_pill_link, :nav_list_link

  def nav_pill_dropdown(title, param, &ye_ol_block)
    css_class = (params[param] ? 'active' : nil)
    close_link =
      if params[param]
        link_to('clear'.html_safe, params.merge(param => nil), class: 'clear')
      end

    content_tag(:li, class: "#{css_class} dropdown") do
      safe_join(
        [
          content_tag(
            :a, "#{title} #{fa_icon('caret-down')}".html_safe,
            class: 'dropdown-toggle', data: { toggle: 'dropdown' }, href: '#'
          ),
          content_tag(:ul, class: 'dropdown-menu') do
            safe_join(
              [
                (close_link ? content_tag(:li, close_link) : nil),
                capture(&ye_ol_block)
              ]
            )
          end
        ]
      )
    end
  end

  def multi_select_nav_pill_dropdown(title, param, _value = true, &ye_ol_block)
    css_class = (Array(params[param]).blank? ? nil : 'active')
    close_link =
      if params[param]
        link_to('clear'.html_safe, params.merge(param => nil), class: 'clear')
      end

    content_tag(:li, class: "#{css_class} dropdown") do
      safe_join(
        [
          content_tag(
            :a, "#{title} #{fa_icon('caret-down')}".html_safe, class: 'dropdown-toggle',
            data: { toggle: 'dropdown' }, href: '#'
          ),
          content_tag(:ul, class: 'dropdown-menu') do
            safe_join([(close_link ? content_tag(:li, close_link) : nil), capture(&ye_ol_block)])
          end
        ]
      )
    end
  end

  def nav_pill_header(title)
    content_tag(:li, class: 'nav-header') do
      title.html_safe
    end
  end
end
