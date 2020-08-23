# frozen_string_literal: true

class AuthorizeApiRequestService
  def initialize(headers = {}, secured_api_version = 'V1')
    @headers = headers
    @secured_api_version = secured_api_version
  end

  def validate_user_token
    api_user
  end

  private

  attr_reader :headers

  def api_user
    return unless decoded_auth_token

    if @secured_api_version == 'V2'
      @api_user ||= ThirdPartyApplication.find_by(
        id: decoded_auth_token[:id],
        api_authorization_client: authorization_client_header
      )
    end

    if @secured_api_version == 'V1'
      @api_user ||= User.find_by(
        id: decoded_auth_token[:user_id],
        jwt_salt: authorization_client_header
      )
    end

    @api_user
  end

  def decoded_auth_token
    @decoded_auth_token ||= JwtTokenService.decode_token(
      authorization_token_header,
      authorization_client_header
    )
  end

  def authorization_token_header
    return nil if headers['Authorization-Token'].blank?

    headers['Authorization-Token'].split(' ').last
  end

  def authorization_client_header
    return nil if headers['Authorization-Client'].blank?

    headers['Authorization-Client']
  end
end
