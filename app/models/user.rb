class User < ApplicationRecord
  validates_presence_of :name, :email, :password_salt, :password_hash

  has_many :sms_mobile_hubs

  class << self
    def persist_values(params)
      password_selected = params[:password]
      cleaned_params = params.except(:password)
      password_salt = BCrypt::Engine.generate_salt

      # We force the password_salt to generate an error
      password_selected.blank? && password_salt = nil

      cleaned_params[:password_salt] = password_salt
      password_hash = { password: password_selected }
      cleaned_params[:password_hash] = encode_token(password_hash, password_salt)
      create(cleaned_params)
    end

    def encode_token(payload, secret_key_base = nil)
      JwtTokenService.encode_token(payload, secret_key_base)
    end

    def decode_token(token, secret_key_base = nil)
      JwtTokenService.decode_token(token, secret_key_base)
    end

    def auth_by_email_and_password(email, password)
      user = find_by(email: email)
      return false unless user

      decoded_token = decode_token(user.password_hash, user.password_salt)
      password_unencrypted = decoded_token[:password]
      return false if password != password_unencrypted

      user
    end
  end
end

