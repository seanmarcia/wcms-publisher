class WebHook
  include ServiceObject
  attr_reader :url

  def initialize(url, errors=[])
    @url = url
    @errors = errors
  end

  def send!(params={})
    raise ArgumentError, "params must be a Hash" unless params.instance_of? Hash
    return if url.blank?
    begin
      post url, params
    rescue => error
      return result_with_errors(error)
    end

    return result_with_success
  end

  private

  def post(url, query={}, error_response=nil)
    response = HTTParty.post(url, body: query)
    if response.code == 200
      return response.body
    else
      # TODO: Log error?
      raise "There was an error calling #{url} with parameters: #{query}"
    end
  end

end
