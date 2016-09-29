class WebHook
  include ServiceObject

  URL = Settings.webhook_url

  def send!(params={})
    raise ArgumentError, "params must be a Hash" unless params.instance_of? Hash
    return if URL.blank?
    begin
      post WebHook::URL, params
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
      raise "There was an error calling #{URL} with parameters: #{query}"
    end
  end

end
