# frozen_string_literal: true

module V2
  # we use the same logic as in V1 but we include different tokens for this one
  # that dont expire never until you request a change in credentials
  # actually if people want to use the other tokens that expire
  # every 12 hours they can do so
  # but they will need to keep generating new tokens
  # and if they use the ones that do not expire no need to do so
  class AuthorizedController < ::V1::ApplicationController
    SECURED_API_VERSION = 'V2'
    before_action :authenticate_request

    private

    def authenticate_request
      service = AuthorizeApiRequestService.new(request.headers, SECURED_API_VERSION)
      @current_api_user = service.validate_user_token

      return if @current_api_user

      error_msg = {
        error: 'You are not authorized to access this resource'
      }

      render_unauthorized_resource(error_msg)
    end
  end
end
