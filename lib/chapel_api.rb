class ChapelApi
  BASE_URL = 'https://apps.biola.edu/chapel/api/v1'

  def academic_years
    get "#{BASE_URL}/academic_years", [] do |body|
      JSON.parse(body)['academic_years']
    end
  end

  def events_for_academic_year(year_id)
    get "#{BASE_URL}/academic_years/#{year_id}/events", [] do |body|
      JSON.parse(body)['events']
    end
  end


  private

  def get(url, error_response=nil)
    response = HTTParty.get(url)
    if response.code == 200
      yield(response.body)
    else
      # TODO: Log error
      error_response
    end
  end
end
