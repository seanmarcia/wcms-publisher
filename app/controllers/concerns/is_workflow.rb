# Transition states for applicable objects and update `transition`_at times
module IsWorkflow
  extend ActiveSupport::Concern

  private

  # Perform state transitions on valid objects when the respective button is clicked
  # @param object [Object] The object to be transitioned.
  # @param params [Hash] ActionController::Parameters
  # @return [true]
  def set_state(object)
    return unless object.valid?
    return unless params[:transition].present?
    transition = params[:transition].to_s.downcase.gsub(/\s/, '_').to_sym
    return unless object.aasm.events.include?(transition)
    return unless policy(object).permitted_aasm_events.include?(transition)
    update_transition_times(transition: transition, object_class: object.class) if object.send(transition)

    true
  end

  # When the transition has been successfully made update the respective
  #  `transition`_at time
  # @param transition [Symbol] Transition performed
  # @param object_class [Class] The class of the object that was transitioned
  # @param params [Hash] ActionController::Parameters
  # @return [true]
  def update_transition_times(transition: nil, object_class: nil)
    type = object_class.to_s.underscore.to_sym

    case transition
    when :publish
      params[type][:publish_at] = Time.now
    when :archive
      params[type][:archive_at] = Time.now
    when :return_to_draft
      params[type][:archive_at] = nil
    end

    true
  end
end
