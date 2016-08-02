# require 'csv'
require 'pg'

namespace :import do

  desc 'Import CSV data dump from Biola Now'
  task now_events: [:environment] do
    if Settings.external_database.now.nil?
      abort "Please add database credentials for now.biola.edu"
    end

    conn = PG.connect(Settings.external_database.now.to_hash)

    puts "---------------\nImporting\n---------------"
    conn.exec("SELECT * FROM events_event") do |result|
      result.each do |row|
        result = BiolaNow::Event.new(row, conn).import
      end
    end

    puts "\n---------------\nAll Done\n---------------"
  end
end
