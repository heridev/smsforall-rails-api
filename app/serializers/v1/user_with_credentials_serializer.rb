# frozen_string_literal: true

module V1
  class UserWithCredentialsSerializer < ::V1::UserSerializer
    attribute :api_authorization_token do |user_object|
      user_object.default_api_keys&.api_authorization_token
    end
    attribute :api_authorization_client do |user_object|
      user_object.default_api_keys&.api_authorization_client
    end
  end
end
