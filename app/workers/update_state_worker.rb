class UpdateStateWorker
  include Sidekiq::Worker

  # This worker does nothing more than resave an exising object which triggers
  #  the aasm state update before_save hook
  # @param klass [String] The class of the object that to be updated.
  # @param obj_id [String] The id of the object to be updated.
  # @return [true]
  def perform(klass, obj_id)
    klass = klass.safe_constantize
    object = klass.find obj_id
    old_aasm = object.aasm_state
    object.save!

    object.reload
    if old_aasm != object.aasm_state
      logger.info %(#{object.aasm_state.titleize} class: #{object.class} id: "#{object.id}")
    elsif old_aasm == object.aasm_state
      logger.info %(No action taken on class: #{object.class} id: "#{object.id}")
    end

    true
  end

end
