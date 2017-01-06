module ActivityTracker
  class PageEdition
    include ServiceObject

    def track!(user, action, page_edition)
      begin
        raise ArgumentError, "ActivityTracker::PageEdition -- page_edition must be an instance of PageEdition not #{page_edition.class}" unless page_edition.class == ::PageEdition
        raise ArgumentError, "ActivityTracker::PageEdition -- user must be an instance of User not #{user.class}" unless user.instance_of? User
        @user = user
        @action = action
        @page_edition = page_edition

        case action
        when :updated
          send_webhook! 'WCMS PageEdition Updated'
        when :destroyed
          send_webhook! 'WCMS PageEdition Destroyed'
        end
      rescue => error
        return result_with_errors(error)
      end

      return result_with_success
    end

    private

    def send_webhook!(msg)
      WebHook.new(Settings.zapier.page_edition_change_webhook_url).send!({
        page_edition: msg,
        user: {name: @user.name, email: @user.email},
        properties: page_edition_properties
      })
    end

    def page_edition_properties
      {
        title: @page_edition.title,
        site: @page_edition.site.url,
        url: @page_edition.url,
        state: @page_edition.aasm_state,
        fields_changed: @page_edition.previous_changes.except(:updated_at, :version).keys.join(', '),
        edit_link: edit_link,
        undo_link: undo_link,
        page_history_link: page_history_link
      }
    end

    def edit_link
      if @action == :updated
        Rails.application.routes.url_helpers.edit_page_edition_url(@page_edition, host: Settings.app.host)
      else
        'n/a'
      end
    end

    def undo_link
      if @action == :destroyed
        Rails.application.routes.url_helpers.undo_destroy_wcms_components_change_url(@page_edition.id, host: Settings.app.host)
      else
        'n/a'
      end
    end

    def page_history_link
      if @action == :updated
        Rails.application.routes.url_helpers.object_index_wcms_components_changes_url(id: @page_edition.id, klass: @page_edition.class, host: Settings.app.host)
      else
        'n/a'
      end
    end
  end
end
