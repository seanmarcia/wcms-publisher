# Import chapels from the chapel databse from specific years
#
# @example
#   ImportChapels.new(['2016-2017']).call
#
class ImportChapels
  attr_reader :import_years
  def initialize(import_years = nil)
    @import_years = import_years || Settings.chapel_import_years || []
  end

  def call
    return false unless site
    all_years.each do |year|
      next unless import_years.include? year['years']
      year_events = Array(api.events_for_academic_year(year['id']))
      year_events.each do |event|
        event['site_id'] = site.id

        if event['type'].try(:strip) == 'NO CHAPEL'
          ChapelApiImportantDate.new(event).import
        else
          ChapelApiEvent.new(event).import
        end
      end
    end
  end

  private

  def site
    @site ||= Site.where(slug: 'biola-edu').first
  end

  def api
    @api ||= ChapelApi.new
  end

  def all_years
    @all_years ||= Array(api.academic_years)
  end
end
