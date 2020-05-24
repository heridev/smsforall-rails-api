# frozen_string_literal: true

module V1
  class UserSessionsController < ::V1::ApplicationController
    def create
      user = User.auth_by_email_and_password(
        params[:email],
        params[:password]
      )

      if user
        user.update_jwt_salt!
        inject_token_headers(user)
        render_serialized(user, UserSerializer)
      else
        render_unauthorized_resource(
          error: 'Las credenciales son incorrectas..'
        )
      end
    end
  end
end
