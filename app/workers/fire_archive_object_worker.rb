class FireArchiveObjectWorker
  include Sidekiq::Worker

  # This worker will fetch classes defined in settings and will save objects
  #  that should be archived
  # @return [true]
  # @note Hits before_save callback in buweb which performs the archive.
  def perform
    logger.info %{Start archiving all objects via aasm.}
    begin
      klasses = Settings.aasm_state_classes.auto_archive
      klasses = klasses.map(&:safe_constantize)

      klasses.each do |klass|
        objects =  klass.should_transition_to_archived

        objects.each do |object|
          UpdateStateWorker.perform_async(klass: klass, obj_id: object.id)
        end
      end
    rescue StandardError => err
      Raven.capture_exception(err) if defined? Raven
      logger.error %{Error: when trying to archive an object. "#{err}"}
    end
    logger.info %{Finish archiving all objects via aasm.}

    true
  end

end
