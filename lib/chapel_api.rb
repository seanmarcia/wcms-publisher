#
# Class for interfacing with the chapel API
# The chapel API is unauthenticated, so these are just
# simple HTTP GET requests.
#
class ChapelApi
  BASE_URL = 'https://apps.biola.edu/chapel/api/v1'.freeze

  # Returns an array of all years in the chapel system
  # @return [Array]
  #   [ { "id": 17, "years": "2016-2017" } ]
  #
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

  def get(url, error_response = nil)
    response = HTTParty.get(url)
    if response.code == 200
      yield(response.body)
    else
      # TODO: Log error
      error_response
    end
  end
end
