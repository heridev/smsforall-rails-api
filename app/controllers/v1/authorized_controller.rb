# frozen_string_literal: true

module V1
  class AuthorizedController < ::V1::ApplicationController
    before_action :authenticate_request

    private

    def authenticate_request
      service = AuthorizeApiRequestService.new(request.headers)
      @current_api_user = service.validate_user_token

      return if @current_api_user

      error_msg = {
        error: 'You are not authorized to access this resource'
      }

      render_unauthorized_resource(error_msg)
    end
  end
end
