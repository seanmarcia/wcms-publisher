class BiolaNow::Event
  attr_reader :id, :source, :event_id, :title, :subtitle, :slug, :teaser,
              :summary, :audience, :admission_info, :contact_name, :contact_email,
              :contact_phone, :location, :map_url, :sponsor, :sponsor_site,
              :registration_info, :image_id, :image_url, :start_date, :end_date,
              :published, :broadcast, :broadcasted, :dates

  def initialize(params, dates = nil)
    @id = params['id']
    @source = params['source']
    @event_id = params['event_id']
    @title = params['title']
    @subtitle = params['subtitle']
    @slug = params['slug']
    @teaser = params['teaser']
    @summary = params['summary']
    @audience = params['audience']
    @admission_info = params['admission_info']
    @contact_name = params['contact_name']
    @contact_email = params['contact_email']
    @contact_phone = params['contact_phone']
    @location = params['location']
    @map_url = params['map_url']
    @sponsor = params['sponsor']
    @sponsor_site = params['sponsor_site']
    @registration_info = params['registration_info']
    @image_id = params['image_id']
    @image_url = params['image_url']
    @start_date = params['start_date']
    @end_date = params['end_date']
    @published = params['published']
    @broadcast = params['broadcast']
    @broadcasted = params['broadcasted']

    # Cache dates (occurrences)
    @dates = dates
  end

  def occurrences
    @occurrences ||= get_occurrences
  end

  def get_occurrences
    return [] if dates.nil?
    if dates.count > 0
      BiolaNow::EventDate.new_from_array(dates)
    else
      [BiolaNow::EventDate.new(start_date: start_date, end_date: end_date)]
    end
  end

  def status
    starts = Chronic.parse(start_date)
    if starts && starts.future?
      'ready_for_review'
    else
      'archived'
    end
  end

  def import(force = false)
    event = Event.find_or_initialize_by({
      import_source: 'biola-now',
      import_id: id,
    })

    # Skip events that have already been imported, unless force is true
    if event.persisted? && !force
      print 's'
      return
    end

    event.assign_attributes({
      title: title,
      subtitle: subtitle,
      # Just buweb automatically generate slug from title
      # slug: slug,
      teaser: teaser,
      description: summary.presence || "No description available",
      # location_type:
      custom_campus_location: location,
      # categories:
      contact_name: contact_name,
      contact_email: contact_email,
      contact_phone: contact_phone,
      # paid:
      imported: true,
      # featured:
      admission_info: admission_info,
      # audience:
      map_url: map_url,
      registration_info: registration_info,
      sponsor: sponsor,
      sponsor_site: sponsor_site,
      aasm_state: status,
      site_id: BSON::ObjectId('556cf04472756208f1030000'), # biola.edu site
    })
    if event.image.file.nil? && image_url.to_s.match(/http/) && !image_url.to_s.match(/\.gif|\.psd/)
      # Do image upload
      event.remote_image_url = image_url
    end

    # Populate event occurrences
    if event.event_occurrences.blank?
      occurrences.each do |o|
        event.event_occurrences << EventOccurrence.new({
          start_time: o.start_time,
          end_time: o.end_time,
          all_day: o.all_day,
        })
      end
    end

    # Try to set site category
    if event.site_categories.blank? && source
      cat_params = {
        site_id: BSON::ObjectId('556cf04472756208f1030000'), # biola.edu site
        type: 'Event',
        title: source.strip,
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
