class ChapelApiEvent
  attr_reader :id, :title, :summary, :scripture,
              :starts_at, :ends_at, :slug, :type,
              :speakers, :series, :location

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
  end

  def subtitle
    speakers.map{|s| s['name']}.join(', ') if speakers.present?
  end

  def site_id
    @site_id ||= Site.where(slug: "biola-edu").first.try(:id)
  end

  def import
    event = Event.find_or_initialize_by({
      import_source: 'chapel-api',
      import_id: id,
    })

    event.assign_attributes({
      title: title,
      subtitle: subtitle,
      description: summary.presence || "No description available",
      contact_email: 'chapel@biola.edu',
      contact_phone: '(562) 903-4874',
      imported: true,
      site_id: site_id,
      audience: ["Students"],
    })

    # Only do this stuff for new events
    unless event.persisted?
      event.assign_attributes({
        aasm_state: 'published',
      })
    end

    # Populate event occurrence
    occurrence = event.event_occurrences.first || event.event_occurrences.new
    occurrence.assign_attributes({
      start_time: starts_at,
      end_time: ends_at,
      all_day: false,
    })

    # Try to set location
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

    # Try setting the department
    if department = Department.where(slug: 'spiritual-development').first
      event.departments = [department]
    end

    # Try to set site category
    if event.site_categories.blank?
      cat_params = {
        site_id: site_id, # biola.edu site
        type: 'Event',
        title: 'Chapel',
      }
      if category = SiteCategory.where(cat_params).first
        event.site_categories = [category]
      end
    end

    if !event.valid?
      puts 'e'
      puts "Error: id(#{id}) - " + event.errors.full_messages.to_sentence
    elsif event.persisted?
      print 'u'
    else
      print '.'
    end

    event.save
  end

end
