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
        Settings.universe[env].academic_publisher + "/academic_programs/#{obj.academic_program.id}/edit?page=concentrations" if obj.present?
      when Department
        Settings.universe[env].profile_publisher + "/offices-services/#{obj.id}" if obj.present?
      when Group
        Settings.universe[env].profile_publisher + "/groups/#{obj.id}" if obj.present?
      when Event
        edit_event_url(obj)
      else
        nil
      end

    link_to "#{text || path} #{fa_icon('external-link')}".html_safe, "#{path}", target: "_blank"
  end
end
