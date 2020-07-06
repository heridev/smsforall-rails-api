class UserWithCredentialsSerializer < UserSerializer
  attribute :api_authorization_token do |object|
    JwtTokenService.encode_token(
      { user_id: object.id },
      object.main_api_token_salt,
      nil
    )
  end
  attribute :api_authorization_client do |object|
    object.main_api_token_salt
  end
end
