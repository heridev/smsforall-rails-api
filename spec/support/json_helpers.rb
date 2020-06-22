module JsonHelpers
  def response_body
    @response_body ||= JSON.parse(response.body, symbolize_names: true)
  end
end
