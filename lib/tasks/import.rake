require 'csv'

namespace :import do

  desc 'Import CSV data dump from Biola Now'
  task now_events: [:environment] do
    puts "---------------\nImporting\n---------------"

    # Process event dates.
    dates = Hash.new([])
    path = "./tmp/biola_now_event_dates.csv"
    CSV.foreach(path, {headers: :first_row}) do |row|
      dates[row["event_id"]] += [row]
    end

    # Import from CSV
    path = "./tmp/biola_now_events.csv"
    CSV.foreach(path, {headers: :first_row}) do |row|
      result = BiolaNow::Event.new(row, dates[row["id"]]).import
    end

    puts "\n---------------\nAll Done\n---------------"
  end

  desc 'Import Chapel events from Chapel api'
  task chapel_events: [:environment] do
    api = ChapelApi.new
    site_id = Site.where(slug: "biola-edu").first.try(:id)

    Array(api.academic_years).each do |year|
      if Settings.chapel_import_years.include? year['years']
        Rails.logger.info "Rake Task [chapel_events]: Importing chapel events for #{year}"
        Array(api.events_for_academic_year(year['id'])).each_with_index do |event, i|
          Rails.logger.info "Rake Task [chapel_events]: [#{i}/#{Array(api.events_for_academic_year(year['id'])).count}] Importing chapel event chapel_id=#{event['id']}"
          event['site_id'] = site_id
          ChapelApiEvent.new(event).import
        end
      end
    end
  end
end
