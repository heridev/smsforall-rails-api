class User < ApplicationRecord
  ### Validations
  validates_presence_of :name, :email, :password_salt, :password_hash
  validates :email, uniqueness: true
  validates :mobile_number, uniqueness: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  ## Associations
  has_many :sms_mobile_hubs

  def update_jwt_salt!
    password_salt = BCrypt::Engine.generate_salt
    update_column(:jwt_salt, password_salt)
    password_salt
  end

  class << self
    def persist_values(params)
      password_selected = params[:password]
      cleaned_params = params.except(:password)
      password_salt = BCrypt::Engine.generate_salt

      # We force the password_salt to generate an error
      password_selected.blank? && password_salt = nil

      password_hash = { password: password_selected }
      cleaned_params[:password_salt] = password_salt
      cleaned_params[:jwt_salt] = BCrypt::Engine.generate_salt
      cleaned_params[:password_hash] = JwtTokenService.encode_token(
        password_hash,
        password_salt,
        nil
      )
      create(cleaned_params)
    end

    def auth_by_email_and_password(email, password)
      user = find_by(email: email)
      return false unless user

      decoded_token = JwtTokenService.decode_token(
        user.password_hash,
        user.password_salt
      )
      return false if decoded_token.blank?

      password_unencrypted = decoded_token[:password]
      return false if password != password_unencrypted

      user
    end
  end
end

