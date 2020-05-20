# frozen_string_literal: true

class JwtTokenService
  JWT_ENCRYPTION_ALG = 'HS256'.freeze

  class << self
    def encode_token(payload, secret_key_base = nil)
      secre_key = get_secret_key(secret_key_base)
      JWT.encode payload, secre_key, JWT_ENCRYPTION_ALG
    end

    def decode_token(token, secret_key_base = nil)
      secret_key = get_secret_key(secret_key_base)
      begin
        decoded_token = JWT.decode token, secret_key, true, { algorithm: JWT_ENCRYPTION_ALG }
        HashWithIndifferentAccess.new decoded_token[0]
      rescue JWT::ExpiredSignature
        nil
        # Handle expired token, e.g. logout user or deny access
      rescue JWT::VerificationError, JWT::DecodeError
        nil
      end
    end

    private

    def get_secret_key(dynamic_salt)
      dynamic_salt || Rails.application.credentials[:secret_key_base]
    end
  end
end
