class User < ApplicationRecord
  ### Validations
  validates_presence_of :name, :email, :password_salt, :password_hash
  validates :email, uniqueness: true
  validates :mobile_number, uniqueness: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  ## Associations
  has_many :sms_mobile_hubs
  has_many :sms_notifications
  has_many :third_party_applications

  STATUSES = {
    default: 'pending_confirmation',
    active: 'active',
    banned: 'banned'
  }.freeze

  def banned?
    status == STATUSES[:banned]
  end

  def active?
    status == STATUSES[:active]
  end

  def pending_confirmation?
    status == STATUSES[:default]
  end

  def valid_pin_number_confirmation?(code)
    pending_confirmation? &&
      registration_pin_code == code
  end

  def confirm_account!(code)
    update(
      registration_pin_code: code,
      signup_completed_at: Time.zone.now,
      status: STATUSES[:active]
    )
  end

  def update_jwt_salt!
    password_salt = BCrypt::Engine.generate_salt
    update_column(:jwt_salt, password_salt)
    password_salt
  end

  def update_pin_number(pin_number)
    return false unless valid_pin_number?(pin_number)

    update_column(
      activation_in_progress: true
    )
  end

  def valid_pin_number?(pin_number)
    activation_in_progress &&
      registration_pin_code == pin_number
  end

  def find_international_number
    "+#{country_international_code}#{mobile_number}"
  end

  def first_ten_chars_from_name
    current_instance = self
    user_name = current_instance.name || ''
    user_name_splitted = user_name.split(' ')
    user_name_splitted.first[0.10]
  end

  def default_api_keys
    @default_api_keys ||= third_party_applications.first
  end

  def create_api_keys(name)
    hash_values = {
      user_id: id,
      name: name
    }

    ThirdPartyApplication.create(hash_values)
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
      user_record_instance = create(cleaned_params)

      if user_record_instance.valid?
        ServiceEnqueuerJob.perform_later(
          'UserPreparatorService',
          'new',
          user_record_instance.id
        )
      end

      user_record_instance
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

