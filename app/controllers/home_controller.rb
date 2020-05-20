class HomeController < ActionController::API
  def index
    api_version_hash = {
      current_version: 'v1',
      domain_name: 'smsparatodos.com'
    }
    render json: api_version_hash
  end
end
