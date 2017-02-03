module RouteHelper
  def source_link_for(obj, options = {})
    env = options[:env] || Rails.env
    text = options[:text]

    path =
      case obj.class
      when AcademicProgram
        Settings.universe[env].academic_publisher + "/academic_programs/#{obj.id}" if obj.present?
      when AcademicSubject
        Settings.universe[env].academic_publisher + "/academic_subjects/#{obj.id}" if obj.present?
      when Concentration
        if obj.present?
          Settings.universe[env].academic_publisher +
            "/academic_programs/#{obj.academic_program.id}/edit?page=concentrations"
        end
      when Department
        Settings.universe[env].profile_publisher + "/offices-services/#{obj.id}" if obj.present?
      when Group
        Settings.universe[env].profile_publisher + "/groups/#{obj.id}" if obj.present?
      when Event
        edit_event_url(obj)
      end

    link_to "#{text || path} #{fa_icon('external-link')}".html_safe, path.to_s, target: '_blank'
  end

  def new_site_button_dropdown(title, &ye_ol_block)
    content_tag(:li, class: 'dropdown') do
      safe_join(
        [
          content_tag(
            :a, fa_icon('caret-down', text: title).to_s.html_safe,
            class: 'dropdown-toggle btn btn-info', data: { toggle: 'dropdown' }, href: '#'
          ),
          content_tag(:ul, class: 'dropdown-menu') do
            capture(&ye_ol_block)
          end
        ]
      )
    end
  end
end
