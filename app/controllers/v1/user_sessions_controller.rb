# frozen_string_literal: true

module V1
  class UserSessionsController < ::V1::AuthorizedController
    skip_before_action :authenticate_request,
                       only: :create
    def create
      user = User.auth_by_email_and_password(
        params[:email],
        params[:password]
      )

      if user
        user.update_jwt_salt!
        inject_token_headers(user)
        render_serialized(user, ::V1::UserSerializer)
      else
        render_unauthorized_resource(
          error: 'Las credenciales son incorrectas..'
        )
      end
    end

    def user_details_by_token
      render_serialized(@current_api_user, ::V1::UserWithCredentialsSerializer)
    end
  end
end
