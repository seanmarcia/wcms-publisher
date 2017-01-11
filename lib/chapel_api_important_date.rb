class ChapelApiImportantDate
  attr_reader :id, :title, :starts_at, :ends_at, :type,
              :important_date, :categories

  def initialize(attrs)
    @id = attrs['id']
    @title = attrs['title']
    @starts_at = attrs['starts_at']
    @ends_at = attrs['ends_at']
    @type = attrs['type']
    @important_date = ImportantDate.find_or_initialize_by(
      import_source: 'chapel-api',
      import_id: id
    )
    log :debug, 'Built new WCMS important date' if important_date.new_record?
    log :debug, 'Found existing WCMS important date' unless important_date.new_record?
  end

  def import
    if important_date.skip_import?
      log :debug, 'SKIPPED - Important Date marked to skip import'
      return false
    end

    important_date.assign_attributes(
      categories: ['Chapel'],
      title: title,
      imported: true,
      start_date: starts_at,
      end_date: ends_at
    )
    important_date.end_date = nil if important_date.end_date <= important_date.start_date

    set_audience
    log_attributes =
      "title='#{important_date.title}' start_date='#{important_date.start_date}'"

    if important_date.changed?
      is_existing_date = important_date.persisted?
      if important_date.save
        if is_existing_date
          print 'u' # updated
        else
          print '.' # created
        end
        log :debug, "Successfully added/updated important date with attributes: #{log_attributes}"
      else
        print 'e'
        log :error, "Error - failed to add/update important date with attributes: "\
          "#{log_attributes} messages=#{important_date.errors.full_messages}"
      end
    else
      log :debug, "No changes - Skip important date with attributes: #{log_attributes}"
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
      "ChapelApiImportantDate#import [chapel_id=#{id}][id=#{important_date.id}]: #{message}"
    Rails.logger.try(level, full_message)
  end

  def set_audience
    important_date.audience_collection = AudienceCollection.new(affiliations: Array(Settings.audience))
  end
end
