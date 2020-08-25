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
        render_serialized(user, ::V1::UserWithCredentialsSerializer)
      else
        render_unauthorized_resource(
          error: 'Las credenciales son incorrectas..'
        )
      end
    end

    def activate_account
      pin_code = params[:user_pin_number]
      if @current_api_user.valid_pin_number_confirmation?(pin_code)
        @current_api_user.confirm_account!(pin_code)
        json_msg = {
          message: 'La cuenta fue activada correctamente'
        }
        render_json_message(json_msg)
      else
        render_with_error('El código es inválido o el usuario ya fue activado')
      end
    end

    def user_details_by_token
      render_serialized(@current_api_user, ::V1::UserWithCredentialsSerializer)
    end
  end
end
