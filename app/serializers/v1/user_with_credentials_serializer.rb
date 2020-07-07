# frozen_string_literal: true

module V1
  class UserWithCredentialsSerializer < ::V1::UserSerializer
    attribute :api_authorization_token do |object|
      JwtTokenService.encode_token(
        { user_id: object.id },
        object.main_api_token_salt,
        nil
      )
    end
    attribute :api_authorization_client, &:main_api_token_salt
  end
end
