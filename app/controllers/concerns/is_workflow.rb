module IsWorkflow
  extend ActiveSupport::Concern

  private

  def set_state(object)
    return unless object.valid?
    return unless params[:transition].present?
    transition = params[:transition].to_s.downcase.gsub(/\s/, '_').to_sym
    return unless object.aasm.events.include?(transition)
    return unless policy(object).permitted_aasm_events.include?(transition)
    object.send(transition)
  end
end
