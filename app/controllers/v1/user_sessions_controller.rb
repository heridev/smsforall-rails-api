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
        render_with_error('Las credenciales son incorrectas..')
      end
    end

    private

    def inject_token_headers(user)
      token_auth = JwtTokenService.encode_token(
        { user_id: user.id },
        user.jwt_salt
      )
      token_response = {
        'Authorization-Token' => token_auth,
        'Authorization-Client' => user.jwt_salt
      }
      response.headers.merge!(token_response)
    end
  end
end
