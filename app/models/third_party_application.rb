class ThirdPartyApplication < ApplicationRecord

  ## Associations
  belongs_to :user

  # Callbacks
  after_create :generate_api_keys

  private

  def generate_api_keys
    api_authorization_client = BCrypt::Engine.generate_salt
    hash_payload = { id: id }

    api_authorization_token = JwtTokenService.encode_token(
      hash_payload,
      api_authorization_client,
      nil
    )
    update_columns(
      api_authorization_client: api_authorization_client,
      api_authorization_token: api_authorization_token
    )
  end
end
