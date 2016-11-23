class FirePublishObjectWorker
  include Sidekiq::Worker

  # This worker will fetch classes defined in setttings and will save objects
  #  that should be published
  # @return [true]
  # @note Hits before_save callback in buweb which publishes.
  def perform
    logger.info %(Start publishing all objects via aasm.)
    klasses = Settings.aasm_state_classes.auto_publish
    klasses = klasses.map(&:safe_constantize)

    klasses.each do |klass|
      objects = klass.should_transition_to_published

      objects.each do |object|
        UpdateStateWorker.perform_async(klass.to_s, object.id)
      end
    end
    logger.info %(Finish publishing all objects via aasm.)

    true
  end
end
