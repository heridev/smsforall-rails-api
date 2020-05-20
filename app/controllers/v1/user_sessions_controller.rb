# frozen_string_literal: true

module V1
  class UserSessionsController < ::V1::ApplicationController
    def create
      user = User.auth_by_email_and_password(
        params[:email],
        params[:password]
      )

      if user
        token_auth = User.encode_token(user_id: user.id)
        render_json_message({ token_auth: token_auth })
      else
        render_with_error('Las credenciales son incorrectas..')
      end
    end
  end
end
