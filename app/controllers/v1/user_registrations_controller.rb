# frozen_string_literal: true

module V1
  class UserRegistrationsController < ::V1::ApplicationController
    def create
      user = User.persist_values(user_params)

      if user.valid?
        inject_token_headers(user)
        render_serialized(
          user,
          UserSerializer
        )
      else
        render_error_object(user.errors.messages)
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :country_international_code,
        :mobile_number
      )
    end
  end
end
