module RouteHelper
  def source_link_for(obj, options = {})
    env = options[:env] || Rails.env
    text = options[:text]

    path = case obj.class
    when AcademicProgram
      Settings.universe[env].academic_publisher + "/academic_programs/#{obj.slug}" if obj.present?
    when AcademicSubject
      Settings.universe[env].academic_publisher + "/academic_subjects/#{obj.slug}" if obj.present?
    when Concentration
      slug = obj.academic_program.slug
      Settings.universe[env].academic_publisher + "/academic_programs/#{slug}/edit?page=concentrations" if obj.present?
    when Department
      Settings.universe[env].profile_publisher + "/offices-services/#{obj.id}" if obj.present?
    when Group
      Settings.universe[env].profile_publisher + "/groups/#{obj.id}" if obj.present?
    when Event
      Settings.universe[env].news_publisher + "/events/#{obj.id}" if obj.present?
    else
      nil
    end

    link_to "#{text || path} #{fa_icon('external-link')}".html_safe, "#{path}", target: "_blank"
  end
end
