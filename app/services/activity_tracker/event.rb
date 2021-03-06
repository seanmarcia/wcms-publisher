module ActivityTracker
  class Event
    include ServiceObject

    def track!(user, action, event)
      begin
        raise ArgumentError, "ActivityTracker::Event -- event must be an instance of Event not #{event.class}" unless event.instance_of? ::Event
        raise ArgumentError, "ActivityTracker::Event -- user must be an instance of User not #{user.class}" unless user.instance_of? User
        @user = user
        @action = action
        @event = event

        case action
        when :created
          track_in_segment 'Event Created in WCMS'
          send_webhook! 'Event Created in WCMS'
        when :updated
          track_in_segment 'Event Updated in WCMS'
          send_webhook! 'Event Updated in WCMS'
        end
      rescue => error
        return result_with_errors(error)
      end

      return result_with_success
    end

    private

    def track_in_segment(event_string)
      Segment::Service.new.track!(@user, event_string, event_properties)
    end

    def send_webhook!(msg)
      WebHook.new(Settings.zapier.event_change_webhook_url).send!({
        event: msg,
        user: {name: @user.name, email: @user.email},
        properties: event_properties
        })
    end

    def event_properties
      {
        title: @event.title,
        site: @event.site.url,
        start_date: @event.start_date.to_s(:long),
        end_date: @event.get_last_occurrence.end_time.try(:to_s, :long),
        occurrences: @event.event_occurrences.count,
        categories: @event.site_categories.pluck(:title).try(:join, ","),
        state: @event.aasm_state,
        edit_link: Rails.application.routes.url_helpers.edit_event_url(@event, host: Settings.app.host)
      }
    end

  end
end
