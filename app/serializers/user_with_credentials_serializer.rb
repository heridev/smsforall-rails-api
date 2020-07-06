class UserWithCredentialsSerializer < UserSerializer
  attribute :api_authorization_token do |object|
    JwtTokenService.encode_token(
      object.id,
      object.password_salt,
      nil
    )
  end
  attribute :api_authorization_client do |object|
    object.main_api_token_salt
  end
end
