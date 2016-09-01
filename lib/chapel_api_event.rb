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
    Rails.logger.debug "ChapelApiEvent#import [chapel_id=#{id}][id=#{event.id.to_s}]: Created new WCMS event" if event.new_record?
    Rails.logger.debug "ChapelApiEvent#import [chapel_id=#{id}][id=#{event.id.to_s}]: Found existing WCMS event" unless event.new_record?
    event.assign_attributes({
      title: title,
      slug: "Chapel #{DateTime.parse(starts_at).strftime('%B %d')} #{title} #{id}".parameterize,
      subtitle: subtitle,
      remote_image_url: image_url,
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
      Rails.logger.debug "ChapelApiEvent#import [chapel_id=#{id}][id=#{event.id.to_s}]: setting aasm_state to 'published'"
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

    # Try setting the presentation_data
    if presentation_data_template
      event.presentation_data_template = presentation_data_template
      event.presentation_data = presentation_data
    end

    if !event.valid?
      puts 'e'
      puts "Error: id(#{id}) - " + event.errors.full_messages.to_sentence
      Rails.logger.error "ChapelApiEvent#import [chapel_id=#{id}][id=#{event.id.to_s}]: Error: - " + event.errors.full_messages.to_sentence
    elsif event.persisted?
      print 'u'
    else
      print '.'
    end

    if event.save
      event.save # temporary work around for indexing the right image url
      Rails.logger.info "ChapelApiEvent#import [chapel_id=#{id}][id=#{event.id.to_s}]: Successfully added/updated event with attributes: slug='#{event.slug}' title='#{event.title}' start_date='#{event.start_date}'"
    else
      Rails.logger.error "ChapelApiEvent#import [chapel_id=#{id}][id=#{event.id.to_s}]: Error - failed to add/update event with attributes: slug='#{event.slug}' title='#{event.title}' start_date='#{event.start_date}'"
    end
  end

  private

  def image_url
    if speakers.present?
      speakers.first['original_photo_url']
    else
      nil # TODO: set default image by `type`
    end
  end

  # finds the PresentationDataTemplate for chapels
  def presentation_data_template
    template = PresentationDataTemplate.where(title: "Chapel Event", target_class: "Event").first
  end

  # has to match the "Chapel Event" PresentationDataTemplate
  def presentation_data
    {
      "type"=>type,
      "scripture"=>scripture,
      "speakers"=> speakers_array,
      "import_data"=>{
        "chapel_id"=>id, 
        "last_imported_at"=>Time.now.to_s(:long)}
    }
  end

  def speakers_array
    arr = []
    speakers.each do |speaker|
      arr << { 
        "name"=>speaker['name'],
        "photo_url"=>speaker['profile_photo_url'],
        "profile"=>speaker['profile']['medium_bio']}
    end
    arr
  end

end
