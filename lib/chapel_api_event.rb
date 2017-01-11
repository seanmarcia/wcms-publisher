class ChapelApiEvent
  attr_reader :id, :title, :summary, :scripture,
              :starts_at, :ends_at, :slug, :type,
              :speakers, :series, :location, :event

  def initialize(attrs)
    @id = attrs['id']
    @title = attrs['title']
    @summary = attrs['summary']
    @scripture = attrs['scripture']
    @starts_at = attrs['starts_at']
    @ends_at = attrs['ends_at']
    @slug = attrs['slug']
    @type = attrs['type']
    @speakers = attrs['speakers']
    @series = attrs['series']
    @location = attrs['location'].try(:[],'name')
    @site_id = attrs['site_id']
    @image_updated = false # a way to force save

    @event = Event.find_or_initialize_by(
      import_source: 'chapel-api',
      import_id: id,
    )
    log :debug, 'Built new WCMS event' if event.new_record?
    log :debug, 'Found existing WCMS event' unless event.new_record?
  end

  def subtitle
    speakers.map { |s| s['name'] }.join(', ') if speakers.present?
  end

  def site_id
    @site_id ||= Site.where(slug: 'biola-edu').first.try(:id)
  end

  def import
    if event.skip_import?
      log :debug, 'SKIPPED - Event marked to skip import'
      return false
    end

    event.assign_attributes(
      title: title,
      slug: "Chapel #{DateTime.parse(starts_at).strftime('%B %d')} #{title} #{id}".parameterize,
      subtitle: subtitle,
      description: summary.presence || 'No description available',
      imported: true,
      site_id: site_id,
      audience: Array(Settings.audience)
    )
    # Only do this stuff for new events
    unless event.persisted?
      event.assign_attributes(
        aasm_state: 'published'
      )
      log :debug, "setting aasm_state to 'published'"
    end

    populate_event_occurrence
    set_location
    set_contact_information
    set_department
    set_site_category
    set_image
    set_presentation_data

    log_attributes =
      "slug='#{event.slug}' title='#{event.title}' start_date='#{event.start_date}'"

    if event.changed? || @image_updated
      is_existing_event = event.persisted?
      if event.save
        if is_existing_event
          print 'u' # updated
        else
          print '.' # created
        end
        event.save # temporary work around for indexing the right image url
        log :debug, "Successfully added/updated event with attributes: #{log_attributes}"
      else
        print 'e'
        log :error, "Error - failed to add/update event with attributes: "\
          "#{log_attributes} messages=#{event.errors.full_messages}"
      end
    else
      log :debug, "No changes - Skip event with attributes: #{log_attributes}"
      print 's' # skipped
    end
  end

  private

  #
  # @param level [Symbol]
  # @param message [String]
  #
  def log(level, message)
    full_message =
      "ChapelApiEvent#import [chapel_id=#{id}][id=#{event.id}]: #{message}"
    Rails.logger.try(level, full_message)
  end

  def populate_event_occurrence
    occurrence = event.event_occurrences.first || event.event_occurrences.new
    occurrence.assign_attributes(
      start_time: starts_at,
      end_time: ends_at,
      all_day: false
    )
  end

  #
  # Find settings for email and phone by event type or use defaults.
  #
  def set_contact_information
    processed_type = type.titleize.parameterize('_')
    contact_info = Settings.chapel_contact_info

    event.contact_email =
      contact_info.try(processed_type).try('email') || contact_info.default_email
    event.contact_phone =
      contact_info.try(processed_type).try('phone') || contact_info.default_phone
  end

  def set_location
    if campus_location = CampusLocation.where(name: location).first
      event.location_type = 'on-campus'
      event.custom_campus_location = nil
      event.campus_location = campus_location
    elsif location.present?
      event.location_type = 'on-campus'
      event.custom_campus_location = location
    else
      event.location_type = 'pending'
    end
  end

  def set_department
    return if event.department_ids.present?
    department = Department.where(slug: 'spiritual-development').first
    return unless department
    event.departments << department
  end

  def set_site_category
    if event.site_category_ids.blank?
      cat_params = {
        site_id: site_id, # biola.edu site
        type: 'Event',
        title: 'Chapel'
      }
      if category = SiteCategory.where(cat_params).first
        event.site_categories << category
      end
    end
  end

  #
  # Use the default photo based on the type of chapel.
  #
  def set_image
    if event.image.url.blank?
      img_src = Rails.root.join("lib/chapel_api/chapel-images/#{default_image}")
      event.image = File.new(img_src)
      @image_updated = true
    end
  end

  # Provide a default image for chapels
  def default_image
    case type
    when 'AfterDark'
      'Chapel-AfterDark.jpg'
    when 'Biola Hour'
      'Chapel-BiolaHour.jpg'
    when 'Sabbathing' || 'Morning Prayer' || 'Thursday Morning Prayer'
      'Chapel-CalvaryChap.jpg'
    when 'Fives'
      'Chapel-Fives.jpg'
    when 'Midday'
      'Chapel-Midday.jpg'
    when 'Singspiration'
      'Chapel-Singspiration.jpg'
    when 'Talbot'
      'Chapel-Talbot.jpg'
    else
      'Chapel-Theme1617.jpg'
    end
  end

  def set_presentation_data
    if event.presentation_data_template_id.blank?
      event.presentation_data_template = presentation_data_template
    end
    event.presentation_data = presentation_data
  end

  # Finds the PresentationDataTemplate for chapels
  def presentation_data_template
    PresentationDataTemplate.where(
      title: 'Chapel Event',
      target_class: 'Event'
    ).first
  end

  # Has to match the "Chapel Event" PresentationDataTemplate
  def presentation_data
    {
      'type' => type,
      'scripture' => scripture,
      'speakers' =>  speakers_array,
      'import_data' => {
        'chapel_id' => id
      }
    }
  end

  def speakers_array
    arr = []
    speakers.each do |speaker|
      arr << {
        'name' => speaker['name'],
        'photo_url' => speaker['profile_photo_url'],
        'profile' => speaker['profile']['medium_bio']
      }
    end
    arr
  end
end
