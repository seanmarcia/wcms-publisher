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
    index = 1
    CSV.foreach(path, {headers: :first_row}) do |row|
      if index == 1
        result = BiolaNow::Event.new(row, dates[row["id"]]).import
      end
      index += 1
    end

    puts "\n---------------\nAll Done\n---------------"
  end
end
