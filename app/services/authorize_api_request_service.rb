# frozen_string_literal: true

class AuthorizeApiRequestService
  def initialize(headers = {})
    @headers = headers
  end

  def validate_user_token
    api_user
  end

  private

  attr_reader :headers

  def api_user
    if decoded_auth_token
      @api_user ||= User.find(
        decoded_auth_token[:user_id]
      )
    end

    @api_user
  end

  def decoded_auth_token
    @decoded_auth_token ||= JwtTokenService.decode_token(http_auth_header)
  end

  def http_auth_header
    return nil if headers['Authorization'].blank?

    headers['Authorization'].split(' ').last
  end
end
