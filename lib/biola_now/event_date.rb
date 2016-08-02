class BiolaNow::EventDate
  # attr_reader :id, :event_id, :start_date, :end_date, :start_time, :end_time

  def initialize(params)
    @id = params['id']
    @event_id = params['event_id']
    @start_date = params['start_date']
    @end_date = params['end_date']
    @start_time = params['start_time']
    @end_time = params['end_time']
  end

  def self.new_from_array(array)
    array.map { |d| BiolaNow::EventDate.new(d) }
  end

  def start_time
    join_date_time(@start_date, @start_time)
  end

  def end_time
    t = join_date_time(@end_date, @end_time)

    # If no time is given, set it to the end of the day.
    @end_time ? t : t.end_of_day
  end

  def all_day
    false
  end

  private

  def join_date_time(date, time)
    if date && time
      Date.parse(date).to_time + Time.parse(time).seconds_since_midnight.seconds
    elsif date && !time
      Date.parse(date).to_time
    end
  end
end
