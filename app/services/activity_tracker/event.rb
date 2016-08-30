module ActivityTracker
  class Event
    include ServiceObject

    def track!(user, action, event)
      begin
        # TODO: fix this; not sure why it stopped working
        #raise ArgumentError, "ActivityTracker::Event -- event must be an instance of Event not #{event.class}" unless event.instance_of? Event
        raise ArgumentError, "ActivityTracker::Event -- user must be an instance of User not #{user.class}" unless user.instance_of? User
        @user = user
        @action = action
        @event = event
        
        case action
        when :created
          result = track_in_segment "Event Created in WCMS"
          result = send_webook! "Event Created in WCMS"
        when :updated
          result = track_in_segment "Updated Event in WCMS"
          result = send_webook! "Updated Event in WCMS"
        when :duplicated
          result = track_in_segment "Duplicated Event in WCMS"
          result = send_webook! "Duplicated Event in WCMS"
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

    def send_webook!(msg)
      WebHook.new.send!({
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
