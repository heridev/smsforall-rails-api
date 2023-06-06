class HomeController < ActionController::API
  def index
    api_version_hash = {
      current_version: 'v1',
      domain_name: 'smsforall.org'
    }
    render json: api_version_hash
  end
end
